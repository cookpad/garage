require 'garage/docs/config'

module Garage
  def self.configure(&block)
    @config = Config::Builder.new(&block).build
  end

  def self.configuration
    @config
  end

  class Config
    DEFAULT_RESCUE_ERROR = true

    attr_writer :cast_resource, :docs, :rescue_error, :strategy
    attr_accessor :auth_server_url, :auth_server_host, :auth_server_timeout

    # Set false if you want to rescue errors by yourself
    # @return [true, false] A flag to rescue Garage::HTTPError in ControllerHelper (default: true)
    # @example
    #   Garage.configuration.rescue_error = false
    def rescue_error
      instance_variable_defined?(:@rescue_error) ? @rescue_error : DEFAULT_RESCUE_ERROR
    end

    # Set authentication strategy module which must satisfy Strategy interface.
    # @return [Module] A auth strategy. default is NoAuthentication strategy.
    # @example
    #   Garage.configuration.strategy = Garage::Strategy::AuthServer
    def strategy
      instance_variable_defined?(:@strategy) ? @strategy : Garage::Strategy::NoAuthentication
    end

    def docs
      @docs ||= Docs::Config.new
    end

    def cast_resource
      @cast_resource ||= proc { |resource|
        if resource.respond_to?(:map)
          resource.map(&:to_resource)
        else
          resource.to_resource
        end
      }
    end

    class Builder
      def initialize(&block)
        @config = Config.new
        instance_eval(&block)
      end

      def build
        @config
      end

      def cast_resource(&block)
        @config.cast_resource = block
      end

      def docs
        @docs_builder ||= Docs::Config::Builder.new(@config.docs)
      end
    end
  end
end
