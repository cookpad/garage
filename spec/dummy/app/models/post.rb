class Post < ActiveRecord::Base
  belongs_to :user, :touch => true
  has_many :comments

  include Garage::Representer
  include Garage::Authorizable

  property :id
  property :title
  property :body, selectable: accessible(PostBody)
  property :tag, as: :label, selectable: true
  property(:comment, selectable: true) { comments.first }
  property :user, selectable: true

  collection :comments, selectable: true
  collection(:numbers, selectable: true) { [1, 2, 3] }

  link(:self) { post_path(self) }

  def tag
    'cat'
  end

  def owner
    user
  end

  def build_permissions(perms, other)
    perms.permits! :read
    perms.permits! :write if owner == other
  end

  def self.build_permissions(perms, other, target)
    if target[:user]
      perms.permits! :read, :write if target[:user] == other
    else
      # public resource i.e. /posts
      perms.permits! :read, :write
    end
  end

  def self.garage_examples(user)
    [:posts_path, Post.first]
  end
end
