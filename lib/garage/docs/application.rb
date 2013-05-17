module Garage
  module Docs
    # Facade class to provide a simple interface to manage Markdown documentation
    # files for the Garage-powered Rails platform apps
    class Application
      attr_reader :parser

      def initialize(app)
        @app = app
      end

      def name
        @app.class.to_s.split('::')[0]
      end

      def docs
        Dir.glob("#{Garage.configuration.docs.document_root}/resources/**/*.md").sort.map {|f| Documentation.new(f) }
      end

      def doc_for(resource)
        docs.find {|doc| doc.resource == resource }
      end

      def resources
        docs.map(&:resource_class)
      end
    end

    class Documentation
      attr_reader :path

      def initialize(path)
        @path = Pathname.new(path)
      end

      def resource_class
        resource.constantize
      end

      def resource
        path.to_s.sub(%r{#{Garage.configuration.docs.document_root}/resources/(.+).md$},'\1').camelize
      end

      def content
        File.open(path).read
      end

      def sections
        @sections ||= parse_sections
      end

      def parse_sections
        sections = []
        content.split("\n").each do |line|
          case line.strip
          when /\A##\s+(.+)\Z/
            sections << MarkdownSection.new($1)
          else
            if sections.last
              sections.last.content << line + "\n"
            end
          end
        end
        sections
      end
    end

    class MarkdownSection
      attr_accessor :title, :content

      def initialize(title)
        @title = title
        @content = ''
      end

      def markup
        Redcarpet::Markdown.new(Redcarpet::Render::HTML, with_toc_data: true, fenced_code_blocks: true).render(@content).html_safe
      end
    end
  end
end
