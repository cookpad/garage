if Rails.gem_version >= Gem::Version.new('4.2.0')
  require 'responders'
else
  require 'action_controller'
end

require "garage/hypermedia_responder"
require "garage/resource_casting_responder"
require "garage/paginating_responder"
require "garage/optional_response_body_responder"

class Garage::AppResponder < ActionController::Responder
  # like Rack middleware, responders are applied outside in, bottom to the top
  include Garage::HypermediaResponder
  include Garage::ResourceCastingResponder
  include Garage::PaginatingResponder
  include Garage::OptionalResponseBodyResponder

  # in case someone tries to do Object#to_msgpack
  undef_method(:to_msgpack) if method_defined?(:to_msgpack)
end
