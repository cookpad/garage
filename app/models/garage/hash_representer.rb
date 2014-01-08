class Garage::HashRepresenter
  include Garage::Representer

  def initialize(object)
    @object = object
  end

  def render_hash(options = {})
    @object
  end
end
