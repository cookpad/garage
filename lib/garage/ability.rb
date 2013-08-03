require "garage/rule"

module Garage
  module Ability
    def rules
      @rules ||= {}
    end

    def can(action, &given_block)
      rules[action] = Rule.new(action, given_block)
    end

    def can?(action, subject)
      rules[action] && rules[action].match?(subject)
    end

    def authorize!(action, subject = nil)
      can?(action, subject) or raise Unauthorized, "Not allowed to process the request operation"
    end
  end
end
