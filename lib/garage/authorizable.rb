module Garage
  module Authorizable
    def effective_permissions(subject)
      raise NotImplementedError, "#{self.class}#effective_permissions must be implemented"
    end

    def authorize!(subject, action)
      effective_permissions(subject).authorize!(action)
    end
  end
end
