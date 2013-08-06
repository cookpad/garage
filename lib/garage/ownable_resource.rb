module Garage
  module OwnableResource
    def owned_by!(user)
      @_owned_by = user
    end

    def owned_by?(user)
      @_owned_by && @_owned_by === user
    end
  end
end
