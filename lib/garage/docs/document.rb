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

      def resource_class
        extract_resource_class || relative_base_name.camelize.singularize.constantize
      end

      def examples(*args)
        resource_class.garage_examples(*args)
      end

      # If you need authentication logic,
      # assign a Proc to Garage.docs.configuration.docs_authorization_method.
      #
      # Example:
      #
      #   Garage.docs.configuration.docs_authorization_method do |args|
      #     if name.start_with?("admin_")
      #       args[:user].admin?
      #     else
      #       true
      #     end
      #   end
      #
      def visible_to?(user)
        if method = Garage.configuration.docs.docs_authorization_method
          method.call(document: self, user: user)
        else
          true
        end
      end

      private

      def extract_resource_class
        if /<!-- resource_class: (\S+)/ === body
          $1.constantize
        end
      end

      def relative_base_name
        pathname.relative_path_from(Pathname.new("#{Garage.configuration.docs.document_root}/resources")).to_s.sub('.md', '')
      end
    end
  end
end
