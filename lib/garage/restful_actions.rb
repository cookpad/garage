module Garage
  module RestfulActions
    extend ActiveSupport::Concern

    included do
      before_filter :require_resource, :only => [:show, :update, :destroy]
      before_filter :require_container_resource, :only => [:index, :create]
      before_filter :require_action_permission_crud, :only => [:index, :create, :show, :update, :destroy]
    end

    # Public: List resources
    def index
      respond_with finalize_resource, respond_with_resources_options
    end

    # Public: Get the resource
    def show
      respond_with finalize_resource, respond_with_resource_options
    end

    # Public: Create a new resource
    def create
      @resource = create_resource
      respond_with finalize_resource, :location => location
    end

    # Public: Update the resource
    def update
      @resource = update_resource
      respond_with finalize_resource
    end

    # Public: Delete the resource
    def destroy
      @resource = destroy_resource
      respond_with finalize_resource
    end

    private

    def finalize_resource
      @resource = @resource.to_resource if @resource.respond_to?(:to_resource)
      @resource
    end

    def current_operation
      if %w[create update destroy].include?(action_name)
        :write
      else
        :read
      end
    end

    def ability_from_token
      Garage::TokenScope.ability(current_resource_owner, doorkeeper_token.scopes)
    end

    def restful_resource_class
      @resource.resource_class
    end

    def require_action_permission
      ability_from_token.access!(restful_resource_class, current_operation)
      @resource.authorize!(current_resource_owner, current_operation)
    end

    # so that controllers can use without breaking built-in CRUD filter
    def require_action_permission_crud
      require_action_permission
    end

    # Override to set @resource
    def require_resource
      raise NotImplementedError, "#{self.class}#require_resource is not implemented"
    end

    # Override to set @resources
    def require_container_resource
      raise NotImplementedError, "#{self.class}#require_container_resource is not implemented"
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
