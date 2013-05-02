module PostRepresenter
  include Platform2::BaseRepresenter

  property :id
  property :title
  property :body
  property :user, :extend => UserRepresenter

  link(:self) { post_path(self) }
end
