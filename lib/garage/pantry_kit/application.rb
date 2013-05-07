require 'tomdoc'
require 'rails/application/route_inspector'

module Garage
  module PantryKit
    # Facade class to provide a simple interface to manage Rails routes,
    # Files and TomDoc documentation for the Platform rails app
    class Application
      attr_reader :parser

      def initialize(app)
        @app = app
        @parser = TomDoc::SourceParser.new
        @doorkeeper = DoorkeeperParser.new
        collect_docs!
      end

      def name
        @app.class.to_s.split('::')[0]
      end

      def collect_docs!
        scan_files(Dir.glob("app/controllers/garage/*.rb"))
      end

      def scan_files(files)
        files.each do |file|
          text = File.read(file)
          @parser.parse(text)
          @doorkeeper.parse(text)
        end
      end

      def docs
        Dir.glob("#{Garage::Docs.config.document_root}/resources/*.md").sort.map {|f| Documentation.new(f) }
      end

      def doc_for(resource)
        docs.find {|doc| doc.resource == resource }
      end

      def resources
        docs.map(&:resource_class)
      end

      def routes_with_docs
        all_routes = @app.routes.routes.select {|r| r.path.spec.to_s.start_with?('/garage/')}
        inspector = Rails::Application::RouteInspector.new

        inspector.collect_routes(all_routes).map {|r| make_action_route(r) }.
          select(&:active?).uniq(&:spec)
      end

      def make_action_route(r)
        route = ActionRoute.new(r)

        if (scope = @parser.scopes[route.controller_sym])
          route.method = scope.instance_methods.find {|m| m.name == route.action }
        end
        if (scope = @doorkeeper.scopes[route.controller_sym])
          route.scopes = scope[route.action.to_sym] || scope[:all]
        end

        route
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
        path.to_s.sub(%r{#{Garage::Docs.config.document_root}/resources/(.+).md$},'\1').camelize
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
        Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(@content).html_safe
      end
    end

    class ActionRoute
      attr_accessor :controller, :action, :method, :scopes

      def initialize(route)
        @route = route

        path, action = route[:reqs].split '#'
        @controller = "#{path.split('/').map(&:camelize).join('::')}Controller".constantize
        @action = action.to_sym
      end

      def api?
        controller.responder == AppResponder
      end

      def resource
        controller.resource_class.to_s
      end

      def spec
        "#{verb} #{path}"
      end

      def verb
        @route[:verb] != '' ? @route[:verb] : 'GET'
      end

      def path
        @path ||= @route[:path].sub(/\(\.:format\)$/, '')
      end

      def path_template
        path.gsub /:user_id/, '{{user_id}}'
      end

      def action_spec
        @route[:reqs]
      end

      def active?
        @method && @route[:name] && @controller.instance_methods.include?(@action)
      end

      def tomdoc
        method.try(:tomdoc)
      end

      def title
        method.try(:tomdoc).try(:description)
      end

      def doc
        tomdoc.try(:tomdoc)
      end

      def title
        tomdoc.description
      end

      def description
        tomdoc.sections[1..-1].try(:join, "\n")
      end

      def controller_sym
        controller.to_s.to_sym
      end
    end

    # Janky regular expression based parser for `doorkeeper_for`
    # hooks. It would be much cleaner if we can inspect controller
    # classes for the installed hooks, but this would work for now.
    class DoorkeeperParser
      attr_reader :scopes

      def initialize
        @scopes = {}
      end

      def parse(text)
        if text.match /class (.*?Controller)/
          @klass = $1.to_sym
          @scopes[@klass] ||= {}

          text.scan /^\s*doorkeeper_for .*$/ do |line|
            instance_eval line
          end
        end
      end

      def doorkeeper_for(*args)
        case args.first
        when :all
          options = args[1] || {}
          @scopes[@klass][:all] = options[:scopes]
        else
          options = args.last.is_a?(Hash) ? args.pop : {}
          args.each do |action|
            @scopes[@klass][action] = options[:scopes]
          end
        end
      end
    end
  end
end
