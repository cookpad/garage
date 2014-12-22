module Garage::OptionalResponseBodyResponder
  protected

  if Rails.version.to_f < 4.2
    def api_behavior(error)
      api_behavior_handler || super
    end
  else
    def api_behavior
      api_behavior_handler || super
    end
  end

  private

  def api_behavior_handler
    case
    when put? && options[:put] && options[:put][:body]
      display resource, status: options[:put][:status] || :ok
    when delete? && options[:delete] && options[:delete][:body]
      display resource, status: options[:delete][:status] || :ok
    else
      nil
    end
  end
end
