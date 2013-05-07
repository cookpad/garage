module Garage
  module Docs
    class Config
      attr_accessor :exampler
      attr_accessor :document_root

      def initialize
        reset
      end

      def reset
        @exampler = Proc.new { [] }
        @document_root = 'doc/garage'
      end
    end
  end
end
