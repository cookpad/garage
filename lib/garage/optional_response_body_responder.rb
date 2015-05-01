module Garage::OptionalResponseBodyResponder
  protected

  def api_behavior(*)
    case
    when put? && options[:put] && options[:put][:body]
      display resource, status: options[:put][:status] || :ok
    when delete? && options[:delete] && options[:delete][:body]
      display resource, status: options[:delete][:status] || :ok
    else
      super
    end
  end
end
