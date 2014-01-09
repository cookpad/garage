module Garage
  module Docs
    class Config
      attr_accessor :document_root, :current_user_method, :authenticate,
        :console_app_uid, :remote_server, :docs_authorization_method, :docs_cache_enabled

      def initialize
        reset
      end

      def reset
        @document_root = Rails.root.join('doc/garage')
        @current_user_method = Proc.new { current_user }
        @authenticate = Proc.new {}
        @console_app_uid = ''
        @remote_server = Proc.new {|request| "#{request.protocol}#{request.host_with_port}" }
        @docs_authorization_method = nil
        @docs_cache_enabled = true
      end

      class Builder
        def initialize(config)
          @config = config
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

        def remote_server=(value)
          @config.remote_server = value
        end

        def docs_cache_enabled=(value)
          @config.docs_cache_enabled = value
        end

        def docs_authorization_method(&block)
          @config.docs_authorization_method = block
        end
      end
    end
  end
end
