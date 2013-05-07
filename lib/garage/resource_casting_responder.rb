module Garage::ResourceCastingResponder
  def display(resource, given_options={})
    resource = Garage.configuration.cast_resource(resource)
    super(resource, given_options)
  end
end
