class Garage::AppResponder < ActionController::Responder
  # like Rack middleware, responders are applied outside in, bottom to the top
  include Garage::HypermediaResponder
#  include Garage::ModelConvertingResponder
  include Garage::PaginatingResponder

  # in case someone tries to do Object#to_msgpack
  undef_method(:to_msgpack) if method_defined?(:to_msgpack)
end
