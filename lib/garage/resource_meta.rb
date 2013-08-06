module Garage
  class ResourceMeta
    def initialize(resource, klass, *args)
      @resource = resource
      @klass = klass
      @args  = args
    end

    def owned_by?(user)
      @args.first && @args.first[:user] === user # FIXME
    end

    def to_resource
      @resource
    end

    def method_missing(method, *args, &block)
      @resource.send(method, *args, &block)
    end
  end
end
