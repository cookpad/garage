module Garage
  def self.configure(&block)
    @config = Config::Builder.new(&block).build
  end

  def self.configuration
    @config
  end

  class Config
    class Builder
      def initialize(&block)
        @config = Config.new
        instance_eval(&block)
      end

      def build
        @config
      end

      def ability(&block)
        @config.instance_variable_set(:@ability, block)
      end

      def cast_resource(&block)
        @config.instance_variable_set(:@cast_resource, block)
      end
    end

    def apply_ability(ability)
      ability.instance_eval &@ability
    end

    def cast_resource(resource)
      if @cast_resource
        @cast_resource.call(resource)
      else
        resource
      end
    end
  end
end
