module Garage
  module Authorizable
    def build_permissions(perms, subject)
      raise NotImplementedError, "#{self.class}#effective_permissions must be implemented"
    end

    def effective_permissions(subject)
      Garage::Permissions.new(subject, resource_class).tap do |perms|
        build_permissions(perms, subject)
      end
    end

    def authorize!(subject, action)
      effective_permissions(subject).authorize!(action)
    end
  end
end
