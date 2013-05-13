require "rails"
require "haml"
require "sass-rails"
require "coffee-rails"
require "garage/docs/application"
require "garage/docs/linkable_example"

module Garage
  module Docs
    class Engine < ::Rails::Engine
      isolate_namespace Garage::Docs
    end
  end
end
