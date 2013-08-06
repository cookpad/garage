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
        resource.owned_by? user
      end
    end

    if scopes.include?(:write_post)
      can :create_post
      can :update_post do |resource|
        resource.owned_by? user
      end
      can :destroy_post do |resource|
        resource.owned_by? user
      end
    end
  end
end
