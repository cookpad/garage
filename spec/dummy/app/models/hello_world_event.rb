class HelloWorldEvent
  def initialize(event)
    @event = event
  end

  def process
    Rails.logger.debug @event
  end
end
