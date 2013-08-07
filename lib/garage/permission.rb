module Garage
  class Permission
    attr_accessor :user, :action

    def initialize(*args)
      @user, @action, @perm = *args
    end

    def allowed?
      @perm == :ok
    end
  end
end
