module Garage
  module Docs
    class Config
      attr_accessor :exampler
      attr_accessor :document_root
      attr_accessor :current_user_method
      attr_accessor :authenticate
      attr_accessor :console_app_uid

      def initialize
        reset
      end

      def reset
        @exampler = Proc.new { [] }
        @document_root = 'doc/garage'
        @current_user_method = Proc.new { current_user }
        @authenticate = Proc.new {}
        @console_app_uid = ''
      end

      class Builder
        def initialize(config)
          @config = config
        end

        def exampler(&block)
          @config.exampler = block
        end

        def document_root=(value)
          @config.document_root = value
        end

        def current_user_method(&block)
          @config.current_user_method = block
        end

        def authenticate(&block)
          @config.authenticate = block
        end

        def console_app_uid=(value)
          @config.console_app_uid = value
        end
      end
    end
  end
end
