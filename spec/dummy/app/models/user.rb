class User < ActiveRecord::Base
  attr_accessible :email, :name

  has_many :posts

  include Garage::Representer

  property :id
  property :name
  property :email

  link(:self) { user_path(self) }
  link(:canonical) { user_path(self) }
  link(:posts) { user_posts_path(self) }

  def self.garage_examples(user)
    [:users_path, user]
  end
end
