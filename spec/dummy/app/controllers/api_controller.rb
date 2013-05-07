class ApiController < ApplicationController
  include Garage::ControllerHelper

  def current_resource_owner
    @current_resource_owner ||= User.find(resource_owner_id) if resource_owner_id
  end

  def current_ability
    @current_ability ||= ::Ability.new(current_resource_owner, doorkeeper_token)
  end
end
