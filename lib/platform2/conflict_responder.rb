module Platform2
  module ConflictResponder
    def display_errors
      if resource.errors.values.flatten.any? { |v| v =~ /has already been taken/ } # *Sigh*
        controller.render format => resource_errors, :status => :conflict
      else
        super
      end
    end
  end
end
