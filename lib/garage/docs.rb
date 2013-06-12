require 'garage/docs/engine'

module Garage
  module Docs
    def self.application
      @application ||= Garage::Docs::Application.new(Rails.application)
    end
  end
end
