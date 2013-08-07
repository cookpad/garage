module Garage
  class Error < ::StandardError; end

  class Unauthorized < Error
    def initialize(user, action, status)
      @status = status
      super "Not allowed to take the requested operation #{action}" # TODO want resource
    end

    def to_status
      @status
    end
  end
end
