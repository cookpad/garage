require 'garage/docs/config'
require 'garage/docs/engine'

module Garage
  module Docs
    def self.config(&block)
      @config ||= Garage::Docs::Config.new
      if block_given?
        block.call(@config)
      else
        @config
      end
    end
  end
end
