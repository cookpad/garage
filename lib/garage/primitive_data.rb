class Garage::PrimitiveData
  include Garage::Representer

  def initialize(object)
    @object = object
  end

  def to_hash(options = {})
    @object
  end
end
