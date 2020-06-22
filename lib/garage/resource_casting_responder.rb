module Garage::ResourceCastingResponder
  def initialize(*args)
    super
    @caster = Garage.configuration.cast_resource
  end

  def display(resource, given_options={})
    if @caster
      resource = @caster.call(resource, @options)
    end
    super(resource, given_options)
  end
end
