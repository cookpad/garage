# Public: represents permissions of the current request user against
# the resource and resource class.
#
# Examples
#
#   class Post
#     include Garage::Authorizable
#
#     def build_permissions(perms, other)
#       perms.permits! :read
#       perms.permits! :write if owner == other
#     end
#
#     def self.build_permissions(perms, other, target)
#       if target[:user]
#         perms.permits! :read, :write if target[:user] == other
#       else
#         perms.permits! :read, :write
#       end
#     end
#   end
require "garage/permission"

module Garage
  class Permissions
    attr_accessor :user, :resource_class

    def initialize(user, resource_class, permissions = { read: :forbidden, write: :forbidden })
      @user = user
      @resource_class = resource_class
      @perms = permissions
    end

    def authorize!(action)
      exists?          or raise PermissionError.new(user, action, resource_class, :not_found)
      permits?(action) or raise PermissionError.new(user, action, resource_class, :forbidden)
    end

    def for(action)
      Permission.new(@user, action, @perms[action])
    end

    def deleted!
      @perms[:deleted] = true
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
