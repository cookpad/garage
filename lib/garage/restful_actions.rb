# Public: mixes in CRUD controller actions to your Action Controller
# classes to provide a simple RESTful actions that provides
# resource-based permissions with built-in integrations with
# Doorkeeper scopes.
#
# Examples
#
#   class PostsController < ApiController
#     include Garage::RestfulActions
#
#     def require_resources
#       @resources = Post.all
#     end
#
#     def require_resource
#       @resource = Post.find(params[:id])
#     end
#   end
module Garage
  module RestfulActions
    extend ActiveSupport::Concern

    included do
      before_filter :require_resource, :only => [:show, :update, :destroy]
      before_filter :require_resources, :only => [:index, :create]
      before_filter :require_action_permission_crud, :only => [:index, :create, :show, :update, :destroy]

      validate_non_authentication!
    end

    module ClassMethods
      def resource_class=(klass)
        @resource_class = klass
      end

      def resource_class
        @resource_class ||= name.sub(/Controller\z/, '').demodulize.singularize.constantize
      end

      private

      # Temporary validation untill authentication option is fully separated.
      def validate_non_authentication!
        if included_modules.include? ::Garage::NoAuthentication
          raise "Don't include RestfulActions after NoAuthentication"
        end
      end
    end

    # Public: List resources
    # Renders `@resources` with options specified with `respond_with_resources_options`
    # Requires `:read` permission on `resource_class` specified for `@resources`
    def index
      respond_with @resources, respond_with_resources_options
    end

    # Public: Get the resource
    # Renders `@resource` with options specified with `respond_with_resource_options`
    # Requries `:read` permission on `@resource`
    def show
      respond_with @resource, respond_with_resource_options
    end

    # Public: Create a new resource
    # Calls `create_resource` in your controller to create a new resource
    # Requires `:write` permission on `resource_class` specified for `@resources`
    def create
      @resource = create_resource
      respond_with @resource, :location => location
    end

    # Public: Update the resource
    # Calls `update_resource` in your controller to update `@resource`
    # Requires `:write` permission on `@resource`
    def update
      @resource = update_resource
      respond_with @resource, respond_with_resource_options
    end

    # Public: Delete the resource
    # Calls `destroy_resource` in your controller to destroy `@resource`
    # Requires `:write` permission on `@resource`
    def destroy
      @resource = destroy_resource
      respond_with @resource, respond_with_resource_options
    end

    private

    # Private: returns either `:read` or `:write`, depending on the current action name
    def current_operation
      if %w[create update destroy].include?(action_name)
        :write
      else
        :read
      end
    end

    # Private: Call this method to require additional permission on
    # extra resource your controller handles. It will check if the
    # current request user has permission to perform the operation
    # (`:read` or `:write`) on the resource.
    #
    # Examples
    #
    #   before_filter :require_recipe
    #   def require_recipe
    #     @recipe = Recipe.find(params[:recipe_id])
    #     require_permission! @recipe, :read
    #   end
    def require_permission!(resource, operation = nil)
      operation ||= current_operation
      resource.authorize!(current_resource_owner, operation)
    end

    # Private: Call this method to require additional access on extra
    # resource class your controller needs access to. It will check if
    # the current request token has an access permission (scope) to
    # perform the operation (`:read` or `:write`) on the resource
    # class.
    #
    # Examples
    #
    #   before_filter :require_stream
    #   def require_stream
    #     require_access! PostStream, :read
    #   end
    def require_access!(resource, operation = nil)
      operation ||= current_operation
      ability_from_token.access!(resource.resource_class, operation)
    end

    # Private: Call this method to require additional access and
    # permission on extra resource your controller performs operation
    # on.
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

    # Private: Call this method if you need to *change* the target
    # resource to provision access and permission.
    #
    #   def require_resources
    #     @resources = Post.where(user_id: @user.id)
    #   end
    #
    # By default, in `index` and `write` actions, Garage will check
    # `:read` and `:write` access respectively on the default
    # `resource_class` of `@resources`, in this case Post class.  If
    # you need more fine grained control than that, you should specify
    # the optional parameters here, such as:
    #
    #   def require_resources
    #     @resources = Post.where(user_id: @user.id)
    #     protect_source_as PrivatePost, user: @user
    #   end
    #
    # This way, the token should require access scope to `PrivatePost`
    # (instead of `Post`), and the authorized user should have a
    # permission to operate the action on resources owned by `@user`
    # (instead of public). The `:user` option will be passed as
    # parameters to `build_permissions` class method.
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

    # Override this if you want to pass options to respond_with in index action
    def respond_with_resources_options
      {}
    end

    # Override this if you want to pass options to respond_with in show action
    def respond_with_resource_options
      {}
    end

    def location
      { action: :show, id: @resource.id } if @resource.try(:respond_to?, :id)
    end
  end
end
