class Ability
  include CanCan::Ability

  def initialize(user, token)
    user ||= User.new
    token ||= Doorkeeper::AccessToken.new
    scopes = token.scopes

    can :show, Post
    can :edit, Post do |post|
      post.user_id == user.id
    end
  end
end
