class Garage::PrimitiveData
  include Garage::BaseRepresenter

  def initialize(object)
    @object = object
  end

  def to_hash(options = {})
    @object
  end
end
