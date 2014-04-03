require 'oj'

module Garage
  module HypermediaResponder
    def display(resource, given_options={})
      given_options[:content_type] = representation.content_type if representation.dictionary?
      super(render(transform(resource)), given_options)
    end

    def render(data)
      DataRenderer.render(data, dictionary: representation.dictionary?)
    end

    def transform(resources)
      if resources.respond_to?(:map)
        resources.map {|resource| encode_to_hash(resource, partial: true) }
      else
        encode_to_hash(resources)
      end
    end

    def encode_to_hash(resource, *args)
      if resource.respond_to?(:id)
        cache_key = "#{resource.class.name}:#{resource.id}"
        cache[cache_key] ||= _encode_to_hash(resource, *args)
      else
        _encode_to_hash(resource, *args)
      end
    end

  private

    def _encode_to_hash(resource, options = {})
      resource.represent!
      resource.params = controller.params.slice(*resource.class.params)
      resource.partial = options[:partial]
      resource.selector = options[:selector] || controller.field_selector
      resource.render_hash(:responder => self)
    end

    def cache
      @cache ||= {}
    end

    def representation
      @representation ||= Representation.new(controller)
    end

    class Representation
      attr_reader :controller

      def initialize(controller)
        @controller = controller
      end

      def dictionary?
        controller.representation == :dictionary
      end

      def content_type
        mime, payload = controller.request.format.to_s.split("/", 2)
        "#{mime}/vnd.cookpad.dictionary+#{payload}"
      end
    end

    class DataRenderer
      JSON_ESCAPE_TABLE = { "<" => '\u003C', ">" => '\u003E' }.freeze

      def self.render(*args)
        new(*args).render
      end

      attr_reader :data, :options

      def initialize(data, options = {})
        @data, @options = data, options
      end

      def render
        Oj.dump(converted_data, mode: :compat).gsub(/([<>])/, JSON_ESCAPE_TABLE)
      end

      private

      def dictionary?
        !!options[:dictionary]
      end

      def convertible_to_dictionary?
        dictionary? && data.is_a?(Array) && data.all? {|datum| datum.respond_to?(:[]) }
      end

      def indexed_data
        data.index_by {|datum| datum["id"] }
      end

      def converted_data
        if convertible_to_dictionary?
          indexed_data
        else
          data
        end
      end
    end
  end
end
