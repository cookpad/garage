module Garage::Representer
  attr_accessor :params, :representer_attrs, :partial, :selector

  def partial?
    @partial
  end

  def render_hash(options={})
    obj = {}
    representer_attrs.each do |definition|
      if definition.options[:if]
        next unless definition.options[:if].call(self, options[:responder])
      end

      if definition.respond_to?(:encode)
        next unless handle_definition?(selector, definition, options)
        obj[definition.name] = definition.encode(self, options[:responder], selector[definition.name])
      else
        next if selector.excludes?('_links')
        block = definition.block
        obj['_links'] ||= {}
        obj['_links'][definition.rel.to_s] = { 'href' => definition.pathify(self) }
      end
    end
    obj
  end

  def handle_definition?(selector, definition, options)
    if definition.requires_select?
      # definition is not selected by default - opt-in
      selector.includes?(definition.name) && definition.selectable?(self, options[:responder])
    else
      # definition is selected by default - it's opt-out
      ! selector.excludes?(definition.name)
    end
  end

  def default_url_options
    @default_url_options ||= {}
  end

  def represent!
    self.representer_attrs ||= []
    self.representer_attrs += self.class.representer_attrs
  end

  def self.representers
    @representers ||= []
  end

  def resource_class
    self.class
  end

  def to_resource
    self
  end

  def link_path_for(rel)
    represent! unless representer_attrs
    representer_attrs.grep(Link).find { |link| link.rel === rel }.try(:pathify, self)
  end

  def self.included(base)
    self.representers << base

    base.class_eval do
      if Rails.application
        include Rails.application.routes.url_helpers
      end
      extend ClassMethods
    end
  end

  module ClassMethods
    def representer_attrs
      @representer_attrs ||= []
    end

    def property(name, options={})
      representer_attrs << Definition.new(name, options)
    end

    def link(rel, options={}, &block)
      representer_attrs << Link.new(rel, options, block)
    end

    def collection(name, options={})
      representer_attrs << Collection.new(name, options)
    end

    def oauth_scope(scope)
      ->(resource, responder){
        # FIXME: this only works with User resource for now
        # partial representation will not render request scope-specific fields for better caching
        !resource.partial? && responder.controller.requested_by?(resource) && responder.controller.has_scope?(scope)
      }
    end

    def accessible(*args)
      ->(resource, responder){
        responder.controller.allow_access?(*args)
      }
    end

    # represents the representer's schema in JSON format
    def metadata
      {:definitions => representer_attrs.grep(Definition).map {|definition| definition.name},
       :links => representer_attrs.grep(Link).map {|link| link.options[:as] ? {link.rel => {'as' => link.options[:as]}} : link.rel}
      }
    end

    def param(*keys)
      keys.each {|key| params << key }
    end

    def params
      @params ||= []
    end
  end

  class NonEncodableValue < StandardError;  end

  class Definition
    attr_reader :options

    def initialize(name, options={})
      @name = name
      @options = options
    end

    def requires_select?
      @options[:selectable]
    end

    def selectable?(*args)
      if boolean?(@options[:selectable])
        @options[:selectable]
      else
        @options[:selectable].call(*args)
      end
    end

    def name
      @options[:as] || @name.to_s
    end

    def encode(object, responder, selector = nil)
      value = object.send(@name)
      encode_value(value, responder, selector)
    end

    def encode_value(value, responder, selector)
      if !value.nil? && value.respond_to?(:represent!)
        responder.encode_to_hash(value, partial: true, selector: selector)
      elsif primitive?(value.class)
        value
      else
        raise NonEncodableValue, "#{value.class} can not be encoded directly. Forgot to include Garage::Representer?"
      end
    end

    def primitive?(klass)
      [
        ActiveSupport::TimeWithZone,
        Bignum,
        Fixnum,
        Float,
        Hash,
        Array,
        String,
        NilClass,
        TrueClass,
        FalseClass
      ].any? {|k| klass.ancestors.include?(k) }
    end

    private

    def boolean?(value)
      value.is_a?(TrueClass) || value.is_a?(FalseClass)
    end
  end

  class Collection < Definition
    def encode(object, responder, selector = nil)
      value = object.send(@name)
      value.map do |item|
        encode_value(item, responder, selector)
      end
    end
  end

  class Link
    attr_reader :rel, :options, :block

    def initialize(rel, options, block)
      @rel, @options, @block = rel, options, block
    end

    def pathify(representer)
      representer.instance_exec &@block
    end
  end
end
