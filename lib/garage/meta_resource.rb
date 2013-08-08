module Garage
  class MetaResource
    include Garage::Authorizable

    attr_reader :resource_class

    def initialize(resource_class, args = {}, &block)
      @resource_class = resource_class
      @args  = args
      @block = block
    end

    def build_permissions(perms, user)
      resource_class.build_permissions(perms, user, @args)
    end

    def build_resource
      @block.call
    end

    def to_resource
      @resource ||= build_resource
    end

    def ===(other)
      if other.is_a?(Class)
        return true if resource_class <= other
      end
      super
    end

    def respond_to?(method, *args)
      super || to_resource.respond_to?(method, *args)
    end

    def method_missing(method, *args, &block)
      if to_resource.respond_to?(method)
        to_resource.send(method, *args, &block)
      else
        super
      end
    end
  end
end
