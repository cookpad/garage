# Public: Garage controller helper for non-authentication usage.
# Include this helper after RestfulActions so that this cancels
# RestfulActions authentication logic.
module Garage
  module NoAuthentication
    extend ActiveSupport::Concern
    include Utils

    included do
      use Rack::AcceptDefault
      respond_to :json # , :msgpack

      self.responder = Garage::AppResponder
      attr_accessor :representation, :field_selector

      before_filter Garage::HypermediaFilter
      skip_before_filter :require_action_permission_crud

      if Garage.configuration.rescue_error
        rescue_from Garage::HTTPError do |exception|
          render json: { status_code: exception.status_code, error: exception.message }, status: exception.status
        end
      end
    end

    # Use this method to specify requested resource_owner_id.
    # It might be nil. Clients are not forced to send Resource-Owner-Id header.
    def resource_owner_id
      request.headers["Resource-Owner-Id"]
    end
  end
end
