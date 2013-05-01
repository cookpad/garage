module Platform2
  module ControllerHelper
    def current_ability
      @current_ability ||= Platform2::Ability.new(current_resource_owner, doorkeeper_token)
    end
  end
end
