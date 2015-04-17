module Garage
  module ControllerHelper
    extend ActiveSupport::Concern
    include Utils

    included do
      use Rack::AcceptDefault

      around_filter :notify_request_stats

      before_action :doorkeeper_authorize!

      # TODO current_user

      if Garage.configuration.rescue_error
        rescue_from Garage::HTTPError do |exception|
          render json: { status_code: exception.status_code, error: exception.message }, status: exception.status
        end
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
