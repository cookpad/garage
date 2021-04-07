class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post

  alias :commenter :user

  def post_owner
    post.user
  end

  include Garage::Representer

  property :id
  property :body
  property :post, selectable: true
  property :commenter # no :selectable here!
  property :post_owner, selectable: true
end
