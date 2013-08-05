module Garage
  class Rule
    def initialize(*args)
      @action, @proc = *args
    end

    def match?(subject)
      @proc ? @proc.call(subject) : true
    end
  end
end
