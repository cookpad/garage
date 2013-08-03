class Ability
  include Garage::Ability

  def initialize(user, token)
    user ||= User.new
    token ||= Doorkeeper::AccessToken.new
    scopes = token.scopes

    can :index_post
    can :show_post
    can :create_post do |post|
      post.user_id = user.id
    end
    can :update_post do |post|
      post.user_id == user.id
    end
    can :destroy_post do |post|
      post.user_id == user.id
    end
  end
end
