module Garage
  module Docs
    class Document
      class << self
        def all
          application.documents
        end

        def find_by_name(name)
          all.find {|document| document.name == name }
        end

        def renderer
          @renderer ||= Redcarpet::Markdown.new(
            Redcarpet::Render::HTML.new(with_toc_data: true),
            fenced_code_blocks: true,
            no_intra_emphasis: true
          )
        end

        def toc_renderer
          @toc_renderer ||= Redcarpet::Markdown.new(
            Redcarpet::Render::HTML_TOC,
            no_intra_emphasis: true
          )
        end

        private

        def application
          Garage::Docs.application
        end
      end

      attr_reader :pathname

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
