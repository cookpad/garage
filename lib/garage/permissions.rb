require "garage/permission"

module Garage
  class Permissions
    attr_accessor :user

    def initialize(user, permissions = { read: :forbidden, write: :forbidden })
      @user = user
      @perms = permissions
      yield self if block_given?
    end

    def for(action)
      Permission.new(@user, action, @perms[action])
    end

    def deleted!
      @perms[:deleted] = false
    end

    def exists?
      !@perms[:deleted]
    end

    def permits!(*actions)
      actions.each do |action|
        @perms[action] = :ok
      end
    end

    def forbids!(*actions)
      actions.each do |action|
        @perms[action] = :forbidden
      end
    end

    def permits?(action)
      self.for(action).allowed?
    end

    def readable?
      permits? :read
    end

    def writable?
      permits? :write
    end
  end
end
