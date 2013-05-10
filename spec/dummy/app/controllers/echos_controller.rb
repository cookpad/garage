class EchosController < ApiController
  def show
    respond_with Garage::HashRepresenter.new(:message => "Hello World")
  end

  def whoami
    respond_with Garage::HashRepresenter(:user_id => current_resource_owner.id)
  end
end
