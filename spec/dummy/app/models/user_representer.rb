module UserRepresenter
  include Garage::BaseRepresenter

  property :id
  property :name
  property :email

  link(:self) { user_path(self) }
  link(:canonical) { user_path(self) }
  link(:posts) { user_posts_path(self) }
end
