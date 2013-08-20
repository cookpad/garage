# Public: proxy object to handle model Class as a resource
module Garage
  class MetaResource
    include Garage::Authorizable

    attr_reader :resource_class

    def initialize(resource_class, args = {})
      @resource_class = resource_class
      @args  = args
    end

    def build_permissions(perms, user)
      resource_class.build_permissions(perms, user, @args)
    end
  end
end
