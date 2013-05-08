class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post

  include Garage::Representer

  property :body
end
