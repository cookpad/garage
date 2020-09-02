require 'json'
require 'net/http'
require 'uri'

require 'garage/tracer'

module Garage
  module Strategy
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

      module Cache
        def self.with_cache(key)
          return yield unless Garage.configuration.cache_acceess_token_validation?

          cached_token = Rails.cache.read(key)
          return cached_token if cached_token && !cached_token.expired?

          token = yield
          Rails.cache.write(key, token, expires_in: default_ttl) if token && token.accessible?
          token
        end

        def self.default_ttl
          Garage.configuration.ttl_for_access_token_cache
        end
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
          if has_any_valid_credentials?
            if has_cacheable_credentials?
              fetch_with_cache
            else
              fetch_without_cache
            end
          else
            nil
          end
        rescue Timeout::Error
          raise AuthBackendTimeout.new(OPEN_TIMEOUT, read_timeout)
        end

        private

        def get
          Tracer.start do |tracer|
            request_header = tracer.inject_trace_context(header)
            tracer.record_http_request('GET', uri.to_s, request_header['User-Agent'])
            raw = http_client.get(path_with_query, request_header)
            tracer.record_http_response(raw.code.to_i, raw['Content-Length'] || 0)
            Response.new(raw)
          end
        end

        def header
          {
            'Authorization' => @request.authorization,
            'Host' => Garage.configuration.auth_server_host,
            'Resource-Owner-Id' => @request.headers['Resource-Owner-Id'],
            'Scopes' => @request.headers['Scopes'],
            'User-Agent' => USER_AGENT,
            # ActionDispatch::Request#request_id is only available in Rails 5.0 or later.
            'X-Request-Id' => @request.uuid,
          }.reject {|_, v| v.nil? }
        end

        def path_with_query
          result = uri.path
          result << "?" + query unless query.empty?
          result
        end

        def query
          @query ||= @request.params.slice(:access_token, :bearer_token).to_query
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

        def has_any_valid_credentials?
          @request.authorization.present? ||
            @request.params[:access_token].present? ||
            @request.params[:bearer_token].present?
        end

        # Cacheable requests are:
        #   - Bearer token request with `Authorization` header.
        #
        # We don't cache these requests because they are less requested:
        #   - Bearer token request with query parameter which has been deprecated.
        #   - Any other token type.
        def has_cacheable_credentials?
          bearer_token.present?
        end

        def bearer_token
          @bearer_token ||= @request.authorization.try {|o| o.slice(/\ABearer\s+(.+)\z/, 1) }
        end

        def fetch_with_cache
          Cache.with_cache("garage_gem/token_cache/#{Garage::VERSION}/#{bearer_token}") do
            fetch_without_cache
          end
        end

        def fetch_without_cache
          response = get
          if response.valid?
            Garage::Strategy::AccessToken.new(response.to_hash)
          else
            if response.status_code == 401
              nil
            else
              raise AuthBackendError.new(response)
            end
          end
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
