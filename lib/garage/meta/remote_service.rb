module Garage
  module Meta
    class RemoteService
      class << self
        def configure(&block)
          @config = Config.new
          @config.instance_eval(&block)
        end

        def configuration
          @config or raise "Garage::Meta::RemoteService.configure must be called in initializer"
        end

        def all
          configuration.services
        end

        def build_permissions(perms, other, target)
          perms.permits! :read
        end
      end

      include Garage::Representer
      include Garage::Authorizable

      property :namespace
      property :name
      property :endpoint
      property :alternate_endpoints

      attr_accessor :namespace, :name, :endpoint

      def alternate_endpoints
        @alternate_endpoints ||= {}
      end

      class Config
        attr_reader :services

        def initialize
          @services = []
        end

        def service(&block)
          service = ServiceDSL.new
          service.instance_eval(&block)
          @services << service.build
        end
      end

      class ServiceDSL
        def initialize
          @service = RemoteService.new
        end

        def namespace(arg)
          @service.namespace = arg.to_s
        end

        def name(arg)
          @service.name = arg
        end

        def endpoint(arg)
          @service.endpoint = arg
        end

        def alternate_endpoint(rel, url)
          @service.alternate_endpoints[rel] = url
        end

        def build
          @service
        end
      end
    end
  end
end
