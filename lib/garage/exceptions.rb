module Garage
  class HTTPError < ::StandardError
    attr_reader :status
    def status_code
      Rack::Utils.status_code(status)
    end
  end

  class Unauthorized < HTTPError
    def initialize(user, action, resource_class, status = :forbidden, scopes = [])
      @status = status
      if scopes.empty?
        super "Authorized user is not allowed to take the requested operation #{action} on #{resource_class}"
      else
        super "Insufficient scope to process the requested operation. Missing scope(s): #{scopes.join(", ")}"
      end
    end
  end
end
