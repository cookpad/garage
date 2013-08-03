module Garage
  module AbilityHelper
    def authorize!(*args)
      current_ability.authorize!(*args)
    end

    def can?(*args)
      current_ability.can?(*args)
    end
  end
end
