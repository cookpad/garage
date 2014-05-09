module Garage
  module ControllerHelper
    extend ActiveSupport::Concern
    included do
      use Rack::AcceptDefault

      around_filter :notify_request_stats

      include ::Doorkeeper::Helpers::Filter
      include Garage::AuthCenter::ControllerHelper if Garage.configuration.enable_auth_center
      doorkeeper_for :all

      # TODO current_user

      rescue_from Garage::HTTPError do |exception|
        render json: { status_code: exception.status_code, error: exception.message }, status: exception.status
      end

      before_filter Garage::HypermediaFilter

      respond_to :json # , :msgpack
      self.responder = Garage::AppResponder
    end

    def doorkeeper_unauthorized_render_options
      { json: { status_code: 401, error: "Unauthorized (invalid token)" } }
    end

    def current_resource_owner
      raise "Your ApplicationController needs to implement current_resource_owner!"
    end

    # Check if the current resource is the same as the requester.
    # The resource must respond to `resource.id` method.
    def requested_by?(resource)
      user = resource.respond_to?(:owner) ? resource.owner : resource
      case
      when current_resource_owner.nil?
        false
      when !user.is_a?(current_resource_owner.class)
        false
      when current_resource_owner.id == user.id
        true
      else
        false
      end
    end

    # Public: returns if the current request includes the given OAuth scope
    def has_scope?(scope)
      doorkeeper_token && doorkeeper_token.scopes.include?(scope)
    end

    def resource_owner_id
      doorkeeper_token.resource_owner_id if doorkeeper_token
    end

    def cache_context
      { t: doorkeeper_token.try(:id) }
    end

    attr_accessor :representation, :field_selector

    def allow_access?(klass, action = :read)
      ability_from_token.allow?(klass, action)
    end

  private

    def ability_from_token
      Garage::TokenScope.ability(current_resource_owner, doorkeeper_token.try(:scopes) || [])
    end

    # TODO move this to ::Utils

    # Private: extract date time range query from query parameters
    # Treat `from` and `to` as aliases for `gte` and `lte` respectively
    def extract_datetime_query(prefix)
      query = {}
      {:from => :gte, :to => :lte, :gt => nil, :lt => nil, :gte => nil, :lte => nil}.each do |key, as|
        k = "#{prefix}.#{key}"
        if params.has_key?(k)
          query[as || key] = fuzzy_parse(params[k]) or raise Garage::BadRequest, "Can't parse datetime #{params[k]}"
        end
      end
      query if query.size > 0
    end

    def fuzzy_parse(date)
      if date.is_a?(Numeric) || /^\d+$/ === date
        Time.zone.at(date.to_i)
      else
        Time.zone.parse(date)
      end
    rescue ArgumentError
      nil
    end

    def notify_request_stats
      yield
    ensure
      begin
        payload = {
          :controller => self,
          :token => doorkeeper_token,
          :resource_owner => current_resource_owner,
        }
        ActiveSupport::Notifications.instrument("garage.request", payload)
      rescue Exception
      end
    end
  end
end
