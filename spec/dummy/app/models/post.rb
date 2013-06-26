class Post < ActiveRecord::Base
  attr_accessible :body, :title

  belongs_to :user, :touch => true
  has_many :comments

  include Garage::Representer

  property :id
  property :title
  property :body, if: scope(:read_post_body)
  property :user, selectable: true

  collection :comments, selectable: true

  link(:self) { post_path(self) }

  def owner
    user
  end
end
