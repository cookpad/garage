class Platform2::AppResponder < ActionController::Responder
  # like Rack middleware, responders are applied outside in, bottom to the top
  include Platform2::HypermediaResponder
#  include Platform2::ModelConvertingResponder
  include Platform2::PaginatingResponder

  # in case someone tries to do Object#to_msgpack
  undef_method(:to_msgpack) if method_defined?(:to_msgpack)
end
