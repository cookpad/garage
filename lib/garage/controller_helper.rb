module Garage
  module ControllerHelper
    extend ActiveSupport::Concern
    include Utils

    included do
      use Rack::AcceptDefault

      around_filter :notify_request_stats

      include Garage.configuration.strategy

      if Garage.configuration.rescue_error
        rescue_from Garage::HTTPError do |exception|
          render json: { status_code: exception.status_code, error: exception.message }, status: exception.status
        end
      end

      before_filter Garage::HypermediaFilter

      respond_to :json # , :msgpack
      self.responder = Garage::AppResponder
    end

    # For backword compatiblility.
    def doorkeeper_token
      access_token
    end

    def resource_owner_id
      access_token.try(:resource_owner_id)
    end

    # Use this method to render 'unauthorized'.
    # Garage user may overwrite this method to response custom unauthorized response.
    # @return [Hash]
    def unauthorized_render_options
      { json: { status_code: 401, error: "Unauthorized (invalid token)" } }
    end

    # Implement by using `resource_owner_id` like:
    #
    #   def current_resource_owner
    #     @current_resource_owner ||= User.find(resource_owner_id) if resource_owner_id
    #   end
    #
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
      access_token && access_token.scopes.include?(scope)
    end

    def cache_context
      { t: access_token.try(:id) }
    end

    attr_accessor :representation, :field_selector

    def allow_access?(klass, action = :read)
      ability_from_token.allow?(klass, action)
    end

  private

    def ability_from_token
      Garage::TokenScope.ability(current_resource_owner, access_token.try(:scopes) || [])
    end

    def notify_request_stats
      yield
    ensure
      begin
        payload = {
          :controller => self,
          :token => access_token,
          :resource_owner => current_resource_owner,
        }
        ActiveSupport::Notifications.instrument("garage.request", payload)
      rescue Exception
      end
    end

    def verify_auth
      if !access_token || !access_token.accessible?
        error_status = :unauthorized
        options = unauthorized_render_options
        render options.merge(status: error_status)
      end
    end
  end
end
