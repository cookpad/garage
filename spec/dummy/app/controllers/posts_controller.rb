class PostsController < ApplicationController
  include Platform2::ControllerHelper

  def index
    authorize! :show, Post
    respond_with Post.all
  end

  def show
    @post = Post.find(params[:id])
    authorize! :show, @post
    respond_with @post
  end

  def update
    @post = Post.find(params[:id])
    authorize! :edit, @post
    @post.update_attributes!(params.slice(:title, :body))
    respond_with @post
  end
end
