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
        @documents ||= pathnames.map {|pathname| Garage::Docs::Document.new(pathname) }
      end

      private

      def pathnames
        Pathname.glob("#{Garage.configuration.docs.document_root}/resources/**/*.md").sort
      end
    end
  end
end
