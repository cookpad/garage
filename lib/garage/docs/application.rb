module Garage
  module Docs
    class Application
      def initialize(application)
        @application = application
      end

      def name
        @application.class.name.split("::")[0]
      end

      def documents
        cached = Garage.configuration.docs.docs_cache_enabled
        @documents ||= pathnames.map {|pathname| Garage::Docs::Document.new(pathname, cached) }
      end

      private

      def pathnames
        Pathname.glob("#{Garage.configuration.docs.document_root}/resources/**/*.md").sort
      end
    end
  end
end
