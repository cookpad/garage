class PostsController < ApiController
  include Garage::RestfulActions

  before_filter :require_hide_resource_authorization, only: :hide
  before_filter :require_capped_resource_authorization, only: :capped

  def hide
    respond_with Post.scoped, paginate: true, hide_total: true
  end

  def capped
    respond_with Post.scoped, paginate: true, hard_limit: 100
  end

  private

  def require_new_resource
    @resource = Post.new
    @resource.user = current_resource_owner
    @resource
  end

  def require_resource
    @resource = Post.find(params[:id])
  end

  def require_resources
    @resources =
      if has_user?
        user.posts
      else
        Post.scoped
      end
  end

  def create_resource
    @resource.update_attributes!(params.slice(:title, :body))
    @resource
  end

  def update_resource
    @resource.update_attributes!(params.slice(:title, :body))
    @resource
  end

  def destroy_resource
    @resource.destroy
  end

  def require_index_resource_authorization
    authorize! :index_post
  end

  def require_hide_resource_authorization
    authorize! :index_post
  end

  def require_capped_resource_authorization
    authorize! :index_post
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
