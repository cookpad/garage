module PostRepresenter
  include Garage::BaseRepresenter

  property :id
  property :title
  property :body
  property :user, :extend => UserRepresenter

  link(:self) { post_path(self) }
end
