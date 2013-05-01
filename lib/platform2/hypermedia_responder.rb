require 'yajl'
module Platform2
  module HypermediaResponder
    ESCAPE_JSON = { '<' => '\u003C', '>' => '\u003E' }.freeze

    MIME_DICT = %r[application/vnd\.cookpad\.dictionary\+(json|x-msgpack)]

    def self.symbolify(subtype)
      subtype.sub(/^x-/, '').to_sym
    end

    def self.filter(controller)
      if MIME_DICT =~ controller.request.format
        controller.representation = :dictionary
        controller.request.format = symbolify($1)
      end

      begin
        fields = controller.params[:fields]
        controller.field_selector = Platform2::NestedFieldQuery::Selector.build(fields)
      rescue Platform2::NestedFieldQuery::InvalidQuery
        raise HTTPStatus::BadRequest, "Invalid query in ?fields="
      end
    end

    def initialize(*args)
      super
      @cache = {}
    end

    def mime_with(representation)
      mime, sub = controller.request.format.to_s.split('/', 2)
      "#{mime}/vnd.cookpad.#{representation.to_s}+#{sub}"
    end

    def display(resource, given_options={})
      if controller.representation == :dictionary
        given_options.merge!(:content_type => mime_with(controller.representation))
      end
      if @options[:cacheable_with]
        delegate = CacheableListDelegate.new(resource, @options[:cacheable_with])
        representation = maybe_cache(delegate, nil, controller.field_selector) {
          transform_representation(resource)
      }
        super(render(representation), given_options)
      else
        super(render(transform_representation(resource)), given_options)
      end
    end

    def render(data)
      if controller.representation == :dictionary
        data = render_dict(data)
      end

      case controller.request.format.to_sym
      when :msgpack
        data.to_msgpack
      else
        # default to JSON
        encode_json_safe(data)
      end
    end

    def render_dict(data)
      # might be prettier to check respond_to? etc. but at this point the data is
      # serialized down to the lowest level structure (Array/Hash)
      if data.is_a?(Array) && (data.empty? || data.first.respond_to?(:[]))
        data.index_by {|entry| entry['id'] }
      end
    end

    def transform_representation(resource)
      if resource.respond_to?(:map!)
        resource.map {|r| encode_to_hash(r, @options[:representer], partial: true, selector: controller.field_selector) }
      else
        encode_to_hash(resource, @options[:representer], selector: controller.field_selector)
      end
    end

    def encode_json_safe(doc)
      # TODO use oj
      Yajl.dump(doc).gsub(/([<>])/) {|c| ESCAPE_JSON[c] }
    end

    def encode_to_hash(resource, *args)
      if resource.respond_to?(:id)
        cache_key = "#{resource.class.name}:#{resource.id}"
        if args[0]
          cache_key = "#{cache_key}:#{args[0]}"
        end
        @cache[cache_key] ||= _encode_to_hash(resource, *args)
      else
        _encode_to_hash(resource, *args)
      end
    end

private

    def _encode_to_hash(resource, representer=nil, options = {})
      representer ||= (resource.class.name + "Representer").constantize
      resource.extend(representer)
      resource.default_url_options = {}
      resource.partial = options[:partial]
      resource.selector = options[:selector]
      maybe_cache(resource, representer, options[:selector]) { resource.to_hash(:responder => self) }
    end

    def maybe_cache(resource, representer, selector, &blk)
      if resource.cacheable? && resource.respond_to?(:cache_key) &&
          /no-cache/ !~ controller.request.headers['Cache-Control']
        key = cache_key_for(resource, representer, selector)
        cached = true
        Rails.cache.fetch(key) {
          cached = false
          blk.call
        }.tap do
          if cached
            Rails.logger.info "Responder Cache HIT: #{key}"
            controller.response.headers['X-Pantry-Cache'] = Rack::Utils.build_query(key)
          end
        end
      else
        blk.call
      end
    end

    def cache_key_for(resource, representer, selector)
      hash = controller.cache_context.merge(r: resource.cache_key)
      hash[:rp] = representer.name if representer
      hash[:s] = selector.canonical if selector
      hash
    end
  end
end

