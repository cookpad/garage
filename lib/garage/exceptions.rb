module Garage
  class Error < ::StandardError; end

  class Unauthorized < Error
    def initialize(user, action, resource_class, status, scopes = [])
      @status = status
      if scopes.empty?
        super "Authorized user is not allowed to take the requested operation"
      else
        super "Insufficient scope to process the requested operation. Missing scope(s): #{scopes.join(", ")}"
      end
    end

    def to_status
      @status
    end
  end
end
