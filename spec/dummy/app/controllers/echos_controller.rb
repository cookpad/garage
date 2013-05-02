class EchosController < ApiController
  def show
    respond_with :message => "Hello World"
  end

  def whoami
    respond_with :user_id => current_resource_owner.id
  end
end
