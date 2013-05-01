module Platform2
  class Engine < ::Rails::Engine
    isolate_namespace Platform2
    config.autoload_paths << File.expand_path('../..', __FILE__)
  end
end
