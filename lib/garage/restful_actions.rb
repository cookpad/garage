module Garage
  module RestfulActions
    extend ActiveSupport::Concern

    included do
      before_filter :require_resource, :only => [:show, :update, :destroy]
      before_filter :require_resources, :only => [:index, :create]
      before_filter :require_action_permission_crud, :only => [:index, :create, :show, :update, :destroy]
      cattr_accessor :resource_class
    end

    # Public: List resources
    def index
      respond_with @resources, respond_with_resources_options
    end

    # Public: Get the resource
    def show
      respond_with @resource, respond_with_resource_options
    end

    # Public: Create a new resource
    def create
      @resource = create_resource
      respond_with @resource, :location => location
    end

    # Public: Update the resource
    def update
      @resource = update_resource
      respond_with @resource
    end

    # Public: Delete the resource
    def destroy
      @resource = destroy_resource
      respond_with @resource
    end

    private

    def current_operation
      if %w[create update destroy].include?(action_name)
        :write
      else
        :read
      end
    end

    def require_permission!(resource, operation = nil)
      operation ||= current_operation
      resource.authorize!(current_resource_owner, operation)
    end

    def require_access!(resource, operation = nil)
      operation ||= current_operation
      ability_from_token.access!(resource.resource_class, operation)
    end

    def require_access_and_permission!(resource, operation = nil)
      require_permission!(resource, operation)
      require_access!(resource, operation)
    end

    def require_action_permission_crud
      if operated_resource
        require_access_and_permission!(operated_resource, current_operation)
      else
        Rails.logger.debug "skipping permissions check since there's no @resource(s) set"
      end
    end

    alias :require_action_permission :require_action_permission_crud

    def protect_resource_as(klass, args = {})
      if klass.is_a?(Hash)
        klass, args = self.class.resource_class, klass
      end
      @operated_resource = MetaResource.new(klass, args)
    end

    def operated_resource
      if @operated_resource
        @operated_resource
      elsif @resources
        MetaResource.new(self.class.resource_class)
      else
        @resource
      end
    end

    # Override to set @resource
    def require_resource
      raise NotImplementedError, "#{self.class}#require_resource is not implemented"
    end

    # Override to set @resources
    def require_resources
      raise NotImplementedError, "#{self.class}#require_resources is not implemented"
    end

    # Override to create a new resource
    def create_resource
      raise NotImplementedError, "#{self.class}#create_resource is not implemented"
    end

    # Override to update @resource
    def update_resource
      raise NotImplementedError, "#{self.class}#update_resource is not implemented"
    end

    # Override to destroy @resource
    def destroy_resource
      raise NotImplementedError, "#{self.class}#destroy_resource is not implemented"
    end

    # Pantry::BookmarkTagsController -> params["bookmark_tag"]
    def resource_params
      params[resource_name]
    end

    # Override this if you want to pass options to respond_with in index action
    def respond_with_resources_options
      {}
    end

    # Override this if you want to pass options to respond_with in show action
    def respond_with_resource_options
      {}
    end

    def location
      { action: :show, id: @resource.id }
    end
  end
end
