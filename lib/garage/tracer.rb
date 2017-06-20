module Garage
  module Tracer
    extend self
    extend Forwardable

    def_delegators :tracer, :start, :inject_trace_context, :record_http_request, :record_http_response

    private

    def tracer
      Garage.configuration.tracer
    end

    # Any tracers must have `.start` to start tracing context and:
    #   - `#inject_trace_context` to add tracing context to the given request header.
    #   - `#record_http_request` to record http request in tracer.
    #   - `#record_http_response` to recrod http response in tracer.
    class NullTracer
      def self.start(&block)
        yield new
      end

      # @param [Hash] header
      # @return [Hash]
      def inject_trace_context(header)
        header
      end

      # @param [String] method
      # @param [String] url
      # @param [String] user_agent
      # @return [nil]
      def record_http_request(method, url, user_agent)
      end

      # @param [Integer] status
      # @param [Integer] content_length
      def record_http_response(status, content_length)
      end
    end

    class AwsXrayTracer
      class << self
        attr_accessor :service
      end

      def self.start(&block)
        yield new
      end

      def inject_trace_context(header)
        header.merge('X-Aws-Xray-Name' => self.class.service)
      end

      def record_http_request(method, url, user_agent)
      end

      def record_http_response(status, content_length)
      end
    end
  end
end
