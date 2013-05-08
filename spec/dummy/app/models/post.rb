class Post < ActiveRecord::Base
  attr_accessible :body, :title

  belongs_to :user, :touch => true

  include Garage::BaseRepresenter

  property :id
  property :title
  property :body
  property :user, includes: true

  link(:self) { post_path(self) }
end
