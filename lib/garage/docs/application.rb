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
        @documents ||= pathnames.map {|pathname| Documentation.new(pathname) }
      end

      def pathnames
        Pathname.glob("#{Garage.configuration.docs.document_root}/resources/**/*.md").sort
      end

      def find_document(name)
        documents.find {|document| document.name == name }
      end
    end

    class Documentation
      attr_reader :pathname

      def self.renderer
        @renderer ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(with_toc_data: true), fenced_code_blocks: true)
      end

      def self.toc_renderer
        @toc_renderer ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML_TOC)
      end

      def initialize(pathname)
        @pathname = pathname
      end

      def name
        pathname.basename(".md").to_s
      end

      def toc
        self.class.toc_renderer.render(body).html_safe
      end

      def render
        self.class.renderer.render(body).html_safe
      end

      def body
        pathname.read
      end
    end
  end
end
