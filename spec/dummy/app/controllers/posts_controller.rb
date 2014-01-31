class PostsController < ApiController
  include Garage::RestfulActions

  before_filter :require_user, only: :private
  before_filter :require_private_resource, only: :private
  before_filter :require_namespaced_resource, only: :namespaced
  before_filter :require_index_resource, only: [:hide, :capped]
  before_filter :require_action_permission, only: [:private, :hide, :capped, :namespaced]

  def private
    respond_with @resources
  end

  def hide
    respond_with @resources, paginate: true, hide_total: true
  end

  def capped
    respond_with @resources, paginate: true, hard_limit: 100
  end

  def namespaced
    respond_with @resources
  end

  private

  def require_user
    @user = user
  end

  def require_resource
    @resource = Post.find(params[:id])
  end

  def require_resources
    if has_user?
      @resources = user.posts
      protect_resource_as user: user
    else
      if params[:stream]
        require_access! Garage::MetaResource.new(PostStream), :read
      end
      @resources = Post.scoped
    end
  end

  def create_resource
    @resource = @resources.new
    @resource.user = current_resource_owner
    @resource.update_attributes!(params.slice(:title, :body))
    @resource
  end

  def update_resource
    @resource.update_attributes!(params.slice(:title, :body))
    @resource
  end

  def destroy_resource
    @resource.destroy
    @resource
  end

  def require_private_resource
    @resources = @user.posts
    protect_resource_as PrivatePost, user: @user
  end

  def require_namespaced_resource
    @resources = Post.all
    protect_resource_as NamespacedPost
  end

  def require_index_resource
    @resources = Post.scoped
  end

  def respond_with_resource_options
    {
      delete: { body: true },
      put: { body: true },
    }
  end

  def respond_with_resources_options
    { paginate: true }
  end

  def has_user?
    params[:user_id]
  end

  def user
    User.find(params[:user_id])
  end
end
