module Garage
  module Webhook
    class Engine < ::Rails::Engine
      isolate_namespace Garage::Webhook

      initializer 'garage.webhook.engine.routes' do
        Engine.routes.append do
          post '/' => 'events#create'
        end
      end
    end
  end
end
