module Garage
  class Ability
    include CanCan::Ability
    attr_reader :user, :token, :scopes

    def initialize(user, token)
#      @user ||= Garage::User.new
      @user = user
      @token = token || Doorkeeper::AccessToken.new
      @scopes = @token.scopes
    end
  end
end
