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

    def self.optional_scopes
      configuration.scopes.values.select(&:optional?)
    end

    def self.hidden_scopes
      configuration.scopes.values.select(&:hidden?)
    end

    def self.ability(user, scopes)
      scopes = scopes.map(&:to_sym)
      scopes = [:public] if scopes.empty? # backward compatiblity for scopes without any scope, assuming public
      Ability.new(user, configuration.scopes.slice(*scopes).values)
    end

    class Ability
      def initialize(user, scopes = [])
        @user = user
        @access = []
        load_scopes(scopes)
      end

      def load_scopes(scopes)
        scopes.each do |scope|
          load_scope(scope)
        end
      end

      def load_scope(scope)
        scope = TokenScope.configuration.scopes[scope] if scope.is_a?(Symbol)
        @access.concat(scope.accessible_resources)
      end

      def missing_scopes(klass, action)
        TokenScope.configuration.required_scopes(klass, action)
      end

      def access!(klass, action)
        allow?(klass, action) or raise MissingScopeError.new(@user, action, klass, :forbidden, missing_scopes(klass, action))
      end

      def allow?(klass, action)
        @access.include?([klass.to_s, action])
      end
    end


    class Config
      def namespace(ns, &block)
        @ns = ns
        instance_eval(&block)
        @ns = nil
      end

      def scopes
        @scopes ||= {}
      end

      def required_scopes(klass, action)
        @required_scopes ||= {}
        @required_scopes[[klass.to_s, action]] ||= []
      end

      def register(scope_symbol, options={}, &block)
        if options[:namespace] || @ns
          scope_symbol = [options[:namespace] || @ns, scope_symbol].join(".").to_sym
        end
        scope = Scope.new(scope_symbol, options)
        scope.instance_eval(&block) if block_given?
        unless scope.hidden?
          scope.accessible_resources.each do |klass, action|
            required_scopes(klass, action) << scope.to_sym
          end
        end

        scopes[scope_symbol] = scope
      end
    end

    class Scope
      attr_reader :description

      def initialize(sym, options={})
        @sym = sym
        @access = []
        @hidden = options[:hidden]
        @description = options[:desc]
      end

      def name
        @sym.to_s
      end
      alias_method :to_s, :name

      def access(action, klass)
        @access << [klass.to_s, action]
      end

      def accessible_resources
        @access
      end

      def to_sym
        @sym
      end

      def hidden?
        !!@hidden
      end

      def optional?
        @sym != :public && !hidden?
      end
    end
  end
end
