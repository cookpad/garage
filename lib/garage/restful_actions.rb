module Garage
  module RestfulActions
    extend ActiveSupport::Concern

    included do
      before_filter :require_resource, :only => [:show, :update, :destroy]
      before_filter :require_resources, :only => :index
      before_filter :require_new_resource, :only => :create
      before_filter :require_index_resource_authorization, :only => :index
      before_filter :require_show_resource_authorization, :only => :show
      before_filter :require_create_resource_authorization, :only => :create
      before_filter :require_update_resource_authorization, :only => :update
      before_filter :require_destroy_resource_authorization, :only => :destroy
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
      resource = create_resource
      respond_with resource, :location => { :action => :show, :id => resource.id }
    end

    # Public: Update the resource
    def update
      respond_with update_resource
    end

    # Public: Delete the resource
    def destroy
      respond_with destroy_resource
    end

    private

    def require_index_resource_authorization
      authorize! authorization_key, current_resource_owner
    end

    def require_show_resource_authorization
      authorize! authorization_key, @resource
    end

    def require_create_resource_authorization
      authorize! authorization_key, @resource
    end

    def require_update_resource_authorization
      authorize! authorization_key, @resource
    end

    def require_destroy_resource_authorization
      authorize! authorization_key, @resource
    end

    # Override to set @resource
    def require_resource
      raise NotImplementedError, "#{self.class}#require_resource is not implemented"
    end

    # Override to set @resources
    def require_resources
      raise NotImplementedError, "#{self.class}#require_resources is not implemented"
    end

    # Override to set @resource
    def require_new_resource
      raise NotImplementedError, "#{self.class}#require_new_resource is not implemented"
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
      { paginate: true }
    end

    # Override this if you want to pass options to respond_with in show action
    def respond_with_resource_options
      {}
    end
  end
end
