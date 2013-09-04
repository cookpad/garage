module Garage
  module Docs
    class Example
      def self.build_all(controller, examples)
        examples.compact.map do |resource|
          new(resource, controller)
        end
      end

      def initialize(resource, controller)
        @resource, @controller = resource, controller
      end

      def url
        if @resource.is_a?(String)
          @resource
        elsif @resource.respond_to?(:to_proc)
          @resource.to_proc.call(@controller.main_app)
        else
          @resource.represent!
          @resource.link_path_for(:self)
        end
      end
    end
  end
end
