module Garage::Representer
  include Rails.application.routes.url_helpers
  attr_accessor :default_url_options, :representer_attrs, :partial, :selector

  def partial?
    @partial
  end

  def cacheable?
    false
  end

  def to_hash(options={})
    obj = {}
    representer_attrs.each do |definition|
      if definition.options[:if]
        next unless definition.options[:if].call(self, options[:responder])
      end

      if definition.respond_to?(:encode)
        next unless handle_definition?(selector, definition)
        obj[definition.name] = definition.encode(self, options[:responder], selector[definition.name])
      else
        next if selector.excludes?('_links')
        block = definition.block
        obj['_links'] ||= {}
        obj['_links'][definition.rel.to_s] = { 'href' => instance_exec(&block) }
      end
    end
    obj
  end

  def handle_definition?(selector, definition)
    if definition.selectable?
      # definition is not selected by default - opt-in
      selector.includes?(definition.name)
    else
      # definition is selected by default - it's opt-out
      ! selector.excludes?(definition.name)
    end
  end

  def represent!
    self.representer_attrs ||= []
    self.representer_attrs += self.class.representer_attrs
  end

  def self.included(base)
    base.class_eval do
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

    def scope(scope)
      lambda { |resource, responder|
        # FIXME: this only works with User resource for now
        # partial representation will not render request scope-specific fields for better caching
        !resource.partial? && responder.controller.request_by?(resource) && responder.controller.has_scope?(scope)
      }
    end
  end

  class NonEncodableValue < StandardError
  end

  class Definition
    attr_reader :options

    def initialize(name, options={})
      @name = name
      @options = options
    end

    def selectable?
      @options[:selectable]
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
      [ ActiveSupport::TimeWithZone, Bignum, Fixnum, Hash, Array, String, NilClass, TrueClass, FalseClass ].include? klass
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
  end
end
