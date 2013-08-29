module Garage
  module Docs
    class Example
      class << self
        def where(args)
          exampler.call(args[:controller], args[:name]).compact.map do |resource|
            new(resource)
          end
        end

        private

        def exampler
          Garage.configuration.docs.exampler
        end
      end

      def initialize(resource)
        @resource = resource
      end

      def url
        if @resource.is_a?(String)
          @resource
        else
          @resource.represent!
          @resource.link_path_for(:self)
        end
      end
    end
  end
end
