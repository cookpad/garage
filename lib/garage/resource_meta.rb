module Garage
  class ResourceMeta
    include Garage::Authorizable

    attr_reader :resource_class

    def initialize(resource, resource_class, args = {})
      @resource = resource
      @resource_class = resource_class
      @args  = args
    end

    def effective_permissions(user)
      resource_class.effective_permissions(user, @args)
    end

    def to_resource
      @resource
    end

    def method_missing(method, *args, &block)
      @resource.send(method, *args, &block)
    end
  end
end
