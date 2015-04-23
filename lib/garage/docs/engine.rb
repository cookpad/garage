require "rails"
require "haml"
require "sass-rails"
require "coffee-rails"
require "garage/docs/renderer"
require "garage/docs/toc_renderer"
require "garage/docs/application"
require "garage/docs/document"
require "garage/docs/example"

module Garage
  module Docs
    class Engine < ::Rails::Engine
      isolate_namespace Garage::Docs

      initializer "garage.docs.engine.routes" do
        Engine.routes.append do
          root :to => 'resources#index', as: nil
          resources :resources do
            collection do
              get 'console'
              post 'authenticate'
              get 'callback'
              post 'callback'
            end
          end
        end
      end
    end
  end
end
