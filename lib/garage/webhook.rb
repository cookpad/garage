require 'garage/webhook/engine'

module Garage
  module Webhook
    def self.configure(&block)
      @config = Configurator.new.build(&block)
    end

    def self.configuration
      @config or raise "Garage::Webhook.configure must be called in intializer"
    end

    class Configurator
      def initialize
        @config = Config.new
      end

      def build(&block)
        instance_eval &block
        @config
      end

      def subscribe(topic, event_class)
        @config.subscriptions[topic] = event_class
      end

      def application_secret(secret)
        @config.application_secret = secret
      end
    end

    class Config
      attr_accessor :application_secret

      def subscriptions
        @subscriptions ||= {}
      end
    end
  end
end
