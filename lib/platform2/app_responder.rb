class Platform2::AppResponder < ActionController::Responder
  # like Rack middleware, responders are applied outside in, bottom to the top
  include Platform2::HypermediaResponder
  include Platform2::ModelConvertingResponder
  include Platform2::PaginatingResponder
  include Platform2::ConflictResponder

  # in case someone tries to do Object#to_msgpack
  undef_method(:to_msgpack) if method_defined?(:to_msgpack)

  def display(*args)
    if controller.respond_to?(:before_display)
      controller.before_display(self, *args)
    end
    super
  end
end
