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
            Garage::Docs::Renderer.new(with_toc_data: true),
            fenced_code_blocks: true,
            no_intra_emphasis: true,
            tables: true,
          )
        end

        def toc_renderer
          @toc_renderer ||= Redcarpet::Markdown.new(
            Garage::Docs::TocRenderer.new,
            no_intra_emphasis: true
          )
        end

        def build_permissions(perms, other, target)
          perms.permits! :read
        end

        private

        def application
          Garage::Docs.application
        end
      end

      include Garage::Authorizable
      include Garage::Representer

      property :name
      property :toc
      property :rendered_body

      attr_reader :pathname
      attr_accessor :cached

      def initialize(pathname, cached = false)
        @pathname = pathname
        @cached = cached
      end

      def name
        relative_base_name.to_s.gsub('/', '-')
      end

      def humanized_name
        name.split('-').map(&:humanize).join(' / ')
      end

      def cache_key(type)
        "garage-doc-#{type}-#{pathname}"
      end

      def toc
        if cached
          Rails.cache.fetch(cache_key(:toc)) do
            self.class.toc_renderer.render(body).html_safe
          end
        else
          self.class.toc_renderer.render(body).html_safe
        end
      end

      def render
        if cached
          Rails.cache.fetch(cache_key(:render)) do
            self.class.renderer.render(body).html_safe
          end
        else
          self.class.renderer.render(body).html_safe
        end
      end

      alias :rendered_body :render

      def body
        pathname.read
      end

      def resource_class
        @resource_class ||= extract_resource_class || relative_base_name.camelize.singularize.constantize
      rescue NameError
        nil
      end

      def examples(*args)
        if resource_class && resource_class.respond_to?(:garage_examples)
          resource_class.garage_examples(*args)
        else
          []
        end
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
