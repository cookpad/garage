module Garage
  def self.configure(&block)
    @config = Config::Builder.new(&block).build
  end

  def self.configuration
    @config
  end

  class Config
    attr_accessor :cast_resource

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
    end
  end
end
