class Post < ActiveRecord::Base
  attr_accessible :body, :title

  belongs_to :user, :touch => true
  has_many :comments

  include Garage::Representer
  include Garage::Authorizable

  property :id
  property :title
  property :body, if: scope(:read_post_body)
  property :user, selectable: true

  collection :comments, selectable: true

  link(:self) { post_path(self) }

  def owner
    user
  end

  def effective_permissions(other)
    Garage::Permissions.new(other) do |perms|
      perms.permits! :read
      perms.permits! :write if owner == other
    end
  end

  def self.effective_permissions(other, target)
    Garage::Permissions.new(other) do |perms|
      if target[:user]
        perms.permits! :read, :write if target[:user] == other
      else
        # public resource i.e. /posts
        perms.permits! :read, :write
      end
    end
  end
end
