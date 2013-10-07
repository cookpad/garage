class ApiController < ApplicationController
  include Garage::ControllerHelper
  include Garage::BackdoorKeeper

  def current_resource_owner
    @current_resource_owner ||= User.find(resource_owner_id) if resource_owner_id
  end

  def resource_owner_exists?(resource_owner_id)
    User.exists?(resource_owner_id)
  end

  def backdoor_privileged_application?(app)
    true
  end
end
