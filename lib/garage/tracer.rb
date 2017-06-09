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
        if Aws::Xray::Context.started?
          Aws::Xray::Context.current.child_trace(remote: true, name: service) do |sub|
            if Aws::Xray::Context.current.respond_to?(:disable_trace)
              Aws::Xray::Context.current.disable_trace(:net_http) { yield new(sub) }
            else
              yield new(sub)
            end
          end
        else
          yield NullTracer.new
        end
      end

      def initialize(sub_segment)
        @sub = sub_segment
      end

      def inject_trace_context(header)
        header.merge('X-Amzn-Trace-Id' => @sub.generate_trace.to_header_value)
      end

      def record_http_request(method, url, user_agent)
        request = Aws::Xray::Request.build(method: method.to_s.upcase, url: url, user_agent: user_agent)
        @sub.set_http_request(request)
      end

      def record_http_response(status, content_length)
        @sub.set_http_response(status, content_length || 0)

        case status
        when 499
          cause = Aws::Xray::Cause.new(stack: caller, message: 'Got 499', type: 'http_request_error')
          @sub.set_error(error: true, throttle: true, cause: cause)
        when 400..498
          cause = Aws::Xray::Cause.new(stack: caller, message: 'Got 4xx', type: 'http_request_error')
          @sub.set_error(error: true, cause: cause)
        when 500..599
          cause = Aws::Xray::Cause.new(stack: caller, message: 'Got 5xx', type: 'http_request_error')
          @sub.set_error(fault: true, remote: true, cause: cause)
        else
          # pass
        end
      end
    end
  end
end
