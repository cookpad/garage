module Platform2
  module Docs
    class Config
      attr_accessor :exampler

      def initialize
        reset
      end

      def reset
        @exampler = Proc.new { [] }
      end
    end
  end
end
