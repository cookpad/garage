require 'platform2/docs/config'
require 'platform2/docs/engine'

module Platform2
  module Docs
    def self.config(&block)
      @config ||= Platform2::Docs::Config.new
      if block_given?
        block.call(@config)
      else
        @config
      end
    end
  end
end
