module Garage
  class Error < ::StandardError; end

  class Unauthorized < Error
    def initialize(user, action, resource_class, status)
      @status = status
      super "Not allowed to take the requested operation #{action} on #{resource_class}"
    end

    def to_status
      @status
    end
  end
end
