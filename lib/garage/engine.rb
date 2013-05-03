module Garage
  class Engine < ::Rails::Engine
    isolate_namespace Garage
    config.autoload_paths << File.expand_path('../..', __FILE__)
  end
end
