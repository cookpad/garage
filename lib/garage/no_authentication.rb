module Garage
  # include after RestfulActions
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

      rescue_from Garage::HTTPError do |exception|
        render json: { status_code: exception.status_code, error: exception.message }, status: exception.status
      end
    end

    def resource_owner_id
      request.headers["Resource-Owner-Id"] or raise Garage::BadRequest.new('Expected Resource-Owner-Id, but empty')
    end

    def has_resource_owner_id?
      !!request.headers["Resource-Owner-Id"]
    end
  end
end
