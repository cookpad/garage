class PostsController < ApiController
  def index
    authorize! :index_post, Post
    if params[:user_id]
      user = User.find(params[:user_id])
      respond_with user.posts, cacheable_with: user, paginate: true
    else
      respond_with Post.scoped, paginate: true
    end
  end

  def hide
    authorize! :index_post, Post
    respond_with Post.scoped, paginate: true, hide_total: true
  end

  def capped
    authorize! :index_post, Post
    respond_with Post.scoped, paginate: true, hard_limit: 100
  end

  def show
    @post = Post.find(params[:id])
    authorize! :show_post, @post
    respond_with @post
  end

  def update
    @post = Post.find(params[:id])
    authorize! :edit_post, @post
    @post.update_attributes!(params.slice(:title, :body))
    respond_with @post
  end
end
