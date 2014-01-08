module Garage
  module Webhook
    class EventsController < Garage::ApplicationController
      before_filter :require_application_secret
      before_filter :verify_webhook

      def create
        handle_event
        render nothing: true, status: 200
      end

      def handle_event
        event_class = find_subscription(params[:channel])
        if event_class.nil?
          # ignore unknown events
        else
          event_class.new(params[:message]).process
        end
      end

      private

      def config
        @config ||= Garage::Webhook.configuration
      end

      def find_subscription(topic)
        config.subscriptions[topic]
      end

      def require_application_secret
        unless config.application_secret
          render json: { error: 'application secret is not configured' }, status: 400
        end
      end

      def verify_webhook
        received = request.headers['Ping-Signature']
        computed = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), config.application_secret, request.raw_post)
        unless Rack::Utils.secure_compare(received, computed)
          render json: { error: 'Signature not verified' }, status: 400
        end
      end
    end
  end
end
