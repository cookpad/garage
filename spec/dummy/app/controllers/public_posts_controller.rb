class PublicPostsController < ApplicationController
  include Garage::RestfulActions
  include Garage::NoAuthentication

  before_filter :require_resource_owner

  def my
    respond_with resource_owner.posts
  end

  private

  def require_resources
    @resources = user.posts
  end

  def user
    User.find(params[:user_id])
  end

  def resource_owner
    @resource_owner ||= User.where(id: resource_owner_id).first
  end

  def require_resource_owner
    unless resource_owner_id && resource_owner
      raise Garage::BadRequest.new('resource_owner_id is empty')
    end
  end
end
