require "rails"
require "haml"
require "sass-rails"
require "coffee-rails"

module Platform2
  module Docs
    class Engine < ::Rails::Engine
      isolate_namespace Platform2::Docs
    end
  end
end
