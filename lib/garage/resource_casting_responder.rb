module Garage::ResourceCastingResponder
  def display(resource, given_options={})
    Garage.configuration.cast_resource(resource)
    super(resource, given_options)
  end
end
