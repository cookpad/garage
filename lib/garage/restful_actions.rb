module Garage
  module RestfulActions
    extend ActiveSupport::Concern

    included do
      before_filter :require_resource, :only => [:show, :update, :destroy]
      before_filter :require_resource_container, :only => [:index, :create]
      before_filter :require_action_permission, :only => [:index, :create, :show, :update, :destroy]
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

    def require_action_permission
      authorize! authorization_key, @resource
    end

    # Override to set @resource
    def require_resource
      raise NotImplementedError, "#{self.class}#require_resource is not implemented"
    end

    # Override to set @resources
    def require_resource_container
      raise NotImplementedError, "#{self.class}#require_resource_container is not implemented"
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

    # Pantry::BookmarkTagsController -> "bookmark_tag"
    def resource_name
      @resource_name ||= self.class.name.split("::").last.sub(/Controller$/, "").singularize.underscore
    end

    # Pantry::BookmarkTagsController -> params["bookmark_tag"]
    def resource_params
      params[resource_name]
    end

    # Pantry::BookmarkTagsController#index -> "index_bookmark_tag"
    def authorization_key
      :"#{action_name}_#{resource_name}"
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
