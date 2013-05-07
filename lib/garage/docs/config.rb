module Garage
  module Docs
    class Config
      attr_accessor :exampler
      attr_accessor :document_root
      attr_accessor :current_user_method

      def initialize
        reset
      end

      def reset
        @exampler = Proc.new { [] }
        @document_root = 'doc/garage'
        @current_user_method = Proc.new { current_user }
      end
    end
  end
end
