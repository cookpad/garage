module PostRepresenter
  include Platform2::BaseRepresenter

  property :id
  property :title
  property :body
  property :user, :extend => UserRepresenter
end
