class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post

  alias :commenter :user

  include Garage::Representer

  property :id
  property :body
  property :commenter, :includes => true
end
