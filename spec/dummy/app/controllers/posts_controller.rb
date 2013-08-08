class PostsController < ApiController
  include Garage::RestfulActions

  before_filter :require_user, only: :private
  before_filter :require_private_resource, only: :private
  before_filter :require_index_resource, only: [:hide, :capped]
  before_filter :require_action_permission, only: [:private, :hide, :capped]

  def private
    respond_with @resource.to_resource # FIXME
  end

  def hide
    respond_with @resource.to_resource, paginate: true, hide_total: true
  end

  def capped
    respond_with @resource.to_resource, paginate: true, hard_limit: 100
  end

  private

  def require_user
    @user = user
  end

  def require_resource
    @resource = Post.find(params[:id])
  end

  def require_container_resource
    if has_user?
      @resource = Garage::MetaResource.new(Post, user: user) { user.posts }
    else
      @resource = Garage::MetaResource.new(Post) { Post.scoped }
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

  def require_private_resource
    @resource = Garage::MetaResource.new(PrivatePost, user: @user) { @user.posts }
  end

  def require_index_resource
    @resource = Garage::MetaResource.new(Post) { Post.scoped }
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
