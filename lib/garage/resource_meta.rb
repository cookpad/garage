module Garage
  class ResourceMeta
    def initialize(resource, klass, args = {})
      @resource = resource
      @klass = klass
      @args  = args
    end

    def effective_permissions(user)
      klass.effective_permissions(user, @args)
    end

    def to_resource
      @resource
    end

    def method_missing(method, *args, &block)
      @resource.send(method, *args, &block)
    end
  end
end
