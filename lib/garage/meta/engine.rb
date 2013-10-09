require "garage/meta/remote_service"

module Garage
  module Meta
    class Engine < ::Rails::Engine
      isolate_namespace Garage::Meta
    end
  end
end
