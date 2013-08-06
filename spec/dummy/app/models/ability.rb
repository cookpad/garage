class Ability
  include Garage::Ability

  def initialize(user, token)
    user ||= User.new
    token ||= Doorkeeper::AccessToken.new
    scopes = token.scopes

    can :index_post
    can :show_post

    if scopes.include?(:read_private_post)
      can :index_private_post do |resource|
        resource.effective_permissions(user).readable?
      end
    end

    if scopes.include?(:write_post)
      can :create_post do |resource|
        resource.effective_permissions(user).writable?
      end
      can :update_post do |resource|
        resource.effective_permissions(user).writable?
      end
      can :destroy_post do |resource|
        resource.effective_permissions(user).writable?
      end
    end
  end
end
