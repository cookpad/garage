require 'json'
require 'net/http'
require 'uri'

module Garage
  module AuthFilter
    module AuthServer
      extend ActiveSupport::Concern

      included do
        before_action :verify_auth, if: -> (_) { verify_permission? }
      end

      def access_token
        if defined?(@access_token)
          @access_token
        else
          @access_token = AccessTokenFetcher.fetch(request)
        end
      end

      def verify_permission?
        true
      end

      # Returns an AccessToken from request object or returns nil if failed.
      class AccessTokenFetcher
        READ_TIMEOUT = 1
        OPEN_TIMEOUT = 1
        USER_AGENT = "Garage #{Garage::VERSION}"

        def self.fetch(*args)
          new(*args).fetch
        end

        def initialize(request)
          @request = request
        end

        def fetch
          if @request.authorization.present?
            response = get
            if response.valid?
              Garage::AuthFilter::AccessToken.new(response.to_hash)
            else
              logger.error("garage-auth_server_error; #{response.status_code}") unless response.status_code == 401
              nil
            end
          else
            logger.info('garage-bad_credentials')
            nil
          end
        rescue Timeout::Error
          logger.error('garage-auth_server_timeout')
          nil
        end

        private

        def get
          raw = http_client.get(uri.path, header)
          Response.new(raw)
        end

        def header
          {
            'Authorization' => @request.authorization,
            'Host' => Garage.configuration.auth_server_host,
            'User-Agent' => USER_AGENT,
          }.reject {|_, v| v.nil? }
        end

        def uri
          @uri ||= URI.parse(auth_server_url)
        end

        def http_client
          client = Net::HTTP.new(uri.host, uri.port)
          client.use_ssl = true if uri.scheme == 'https'
          client.read_timeout = read_timeout
          client.open_timeout = OPEN_TIMEOUT
          client
        end

        def auth_server_url
          Garage.configuration.auth_server_url or raise NoUrlError
        end

        def read_timeout
          Garage.configuration.auth_server_timeout or READ_TIMEOUT
        end

        def logger
          Rails.logger
        end
      end

      class Response
        def initialize(raw)
          @raw = raw
        end

        def valid?
          status_code == 200 && json? && parsed_body.is_a?(Hash)
        end

        def to_hash
          parsed_body.symbolize_keys
        end

        def status_code
          @raw.code.to_i
        end

        def body
          @raw.body
        end

        private

        def json?
          parsed_body
          true
        rescue JSON::ParserError
          false
        end

        def parsed_body
          @parsed_body ||= JSON.parse(body)
        end
      end

      class NoUrlError < StandardError
        def message
          'You must set Garage.configuration.auth_server_url'
        end
      end
    end
  end
end
