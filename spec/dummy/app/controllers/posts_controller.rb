class PostsController < ApiController
  include Garage::RestfulActions

  before_filter :require_user, only: :private
  before_filter :require_private_resource, only: :private
  before_filter :require_private_resource_authorization, only: :private

  before_filter :require_hide_resource_authorization, only: :hide
  before_filter :require_capped_resource_authorization, only: :capped

  def private
    respond_with @resource
  end

  def hide
    respond_with Post.scoped, paginate: true, hide_total: true
  end

  def capped
    respond_with Post.scoped, paginate: true, hard_limit: 100
  end

  private

  def require_user
    @user = user
  end

  def require_resource
    @resource = Post.find(params[:id])
  end

  def require_resource_container
    if has_user?
      @resource = user.posts
    else
      @resource = Post.scoped
    end
  end

  def create_resource
    @resource = @resource.new
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

  def require_index_resource_authorization
    authorize! :index_post, @resource
  end

  def require_hide_resource_authorization
    authorize! :index_post, @resource
  end

  def require_capped_resource_authorization
    authorize! :index_post, @resource
  end

  def require_private_resource
    @resource = @user.posts
    user = @user
    @resource.define_singleton_method(:user) { user }
    @resource
  end

  def require_private_resource_authorization
    authorize! :index_private_post, @resource
  end

  def respond_with_resources_options
    options = { paginate: true }
    options[:cacheable_with] = user if has_user?
    options
  end

  def has_user?
    params[:user_id]
  end

  def user
    User.find(params[:user_id])
  end
end
