class EchosController < ApiController
  def show
    respond_with Garage::HashRepresenter.new(:message => "Hello World")
  end
end
