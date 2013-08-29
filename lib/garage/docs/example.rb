module Garage
  module Docs
    class Example
      class << self
        def where(args)
          exampler.call(args[:controller], args[:name]).compact.map do |path|
            new(controller: args[:controller], path: path)
          end
        end

        private

        def exampler
          Garage.configuration.docs.exampler
        end
      end

      def initialize(args)
        @controller = args[:controller]
        @path = args[:path]
      end

      def url
        if @path.is_a?(String)
          @path
        else
          rendered = Garage::AppResponder.new(@controller, [@path]).
            encode_to_hash(@path, selector: Garage::NestedFieldQuery::DefaultSelector.new)
          rendered['_links']['self']['href']
        end
      end
    end
  end
end
