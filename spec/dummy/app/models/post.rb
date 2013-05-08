class Post < ActiveRecord::Base
  attr_accessible :body, :title

  belongs_to :user, :touch => true
  has_many :comments

  include Garage::Representer

  property :id
  property :title
  property :body
  property :user, includes: true

  collection :comments

  link(:self) { post_path(self) }
end
