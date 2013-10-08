module Garage
  module Meta
    class ServicesController < Garage::ApplicationController
      include Garage::RestfulActions
      include Garage::ControllerHelper

      self.resource_class = Garage::Meta::RemoteService

      def current_resource_owner
        nil
      end

      private

      def require_resources
        @resources = Garage::Meta::RemoteService.all
      end
    end
  end
end
