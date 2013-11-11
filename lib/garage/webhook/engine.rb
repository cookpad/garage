module Garage
  module Webhook
    class Engine < ::Rails::Engine
      isolate_namespace Garage::Webhook
    end
  end
end
