module Garage
  class TokenScope
    def self.configure(&block)
      @config = Config.new
      @config.instance_eval(&block)
    end

    def self.configuration
      @config or raise "Garage::TokenScope.configure must be called in initializer"
    end

    def self.all_scopes
      configuration.scopes.values
    end

    def self.ability(user, scopes)
      scopes = scopes.map(&:to_sym)
      scopes = [:public] if scopes.empty? # backward compatiblity for scopes without any scope, assuming public
      ability = Ability.new(user, configuration.scopes.slice(*scopes).values.map(&:accessible_resources).flatten(1))
    end

    class Ability
      def initialize(user, access)
        @user = user
        @access = access
      end

      def missing_scopes(klass, action)
        TokenScope.configuration.required_scopes(klass, action)
      end

      def access!(klass, action)
        allow?(klass, action) or raise Garage::Unauthorized.new(@user, action, klass, :forbidden, missing_scopes(klass, action))
      end

      def allow?(klass, action)
        @access.include?([klass.to_s, action])
      end
    end


    class Config
      def scopes
        @scopes ||= {}
      end

      def required_scopes(klass, action)
        @required_scopes ||= {}
        @required_scopes[[klass.to_s, action]] ||= []
      end

      def register(scope_symbol, &block)
        scope = Scope.new(scope_symbol)
        scope.instance_eval(&block) if block_given?
        scope.accessible_resources.each do |klass, action|
          required_scopes(klass, action) << scope.to_sym
        end

        scopes[scope_symbol] = scope
      end
    end

    class Scope
      def initialize(sym)
        @sym = sym
        @access = []
      end

      def access(action, klass)
        @access << [klass.to_s, action]
      end

      def accessible_resources
        @access
      end

      def to_sym
        @sym
      end
    end
  end
end
