class HelloWorldEvent
  def initialize(event)
    @event = event
  end

  def process
    p @event
  end
end
