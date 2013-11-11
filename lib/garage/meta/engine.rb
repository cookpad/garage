require "garage/meta/remote_service"

module Garage
  module Meta
    class Engine < ::Rails::Engine
      isolate_namespace Garage::Meta

      initializer "garage.meta.engine.routes" do
        Engine.routes.append do
          resources :services
          resources :docs
        end
      end
    end
  end
end
