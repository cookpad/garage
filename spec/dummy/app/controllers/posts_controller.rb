class PostsController < ApplicationController
  def show
    respond_with Post.new(params[:id])
  end
end
