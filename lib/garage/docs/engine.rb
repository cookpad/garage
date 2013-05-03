require "rails"
require "haml"
require "sass-rails"
require "coffee-rails"

module Garage
  module Docs
    class Engine < ::Rails::Engine
      isolate_namespace Garage::Docs
    end
  end
end
