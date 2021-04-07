module Garage
  module NestedFieldQuery
    class InvalidQuery < StandardError; end
    class InvalidData < StandardError; end

    class Parser
      def self.parse(*args)
        new.parse(*args)
      end

      def parse(given_query, indent = nil)
        parse_recurse(given_query.to_s.dup, indent)
      end

    private

      def parse_recurse(query, indent)
        result = []
        current = nil
        while query.sub!(/^(?:\s*([\w\.\*]+)|(,)|(\[)|(\]))/, '')
          if $1
            current = $1.to_s
          elsif $2
            if current
              result << current
              current = nil
            else
              raise InvalidQuery, "Expected field name: #{query}"
            end
          elsif $3
            if current
              current = { current => parse_recurse(query, 1) }
            else
              raise InvalidQuery, "'[' should come after field: #{query}"
            end
          elsif $4
            if indent
              if current
                result << current
                return merge(result)
              else
                raise InvalidQuery, "']' should be after '[field': #{query}"
              end
            else
              raise InvalidQuery, "']' should be after '[field': #{query}"
            end
          end
        end

        if current
          result << current
        else
          raise InvalidQuery, "premature end of query"
        end

        merge(result)
      end

      def merge(result)
        hash = Hash.new
        result.each do |res|
          if res.is_a?(Hash)
            hash.merge!(res)
          else
            hash[res] = nil
          end
        end
        hash
      end
    end

    class Builder
      def self.build(*args)
        new.build(*args)
      end

      def build(arg)
        val = ''

        case arg
        when Hash
          val << arg.map { |key, value|
            if value.nil?
              key
            else
              "#{key}[#{build(value)}]"
            end
          }.join(',')
        when Symbol, String
          val << arg.to_s
        else
          raise InvalidData, "Can't encode data type: #{arg.class}"
        end

        val
      end
    end

    class DefaultSelector
      # kinda NullObject pattern

      def initialize(accepted_nest_depth = nil)
        @accepted_nest_depth = accepted_nest_depth || 5
      end

      # Doesn't specify anything - includes/excludes returns both false :)

      def includes?(field)
        false
      end

      def excludes?(field)
        false
      end

      def eof?
        @accepted_nest_depth && @accepted_nest_depth < 0
      end

      def [](name)
        DefaultSelector.new(@accepted_nest_depth - 1)
      end

      def canonical
        ''
      end
    end

    class FullSelector < DefaultSelector
      def includes?(field)
        true
      end

      def excludes?(field)
        false
      end

      def [](name)
        FullSelector.new(@accepted_nest_depth - 1)
      end

      def canonical
        '*'
      end
    end

    class Selector
      # includes eager loading

      def self.build(fields, accepted_nest_depth = nil)
        if fields.present?
          build_parsed(Parser.parse(fields), accepted_nest_depth)
        else
          NestedFieldQuery::DefaultSelector.new(accepted_nest_depth)
        end
      end

      def self.build_parsed(fields, accepted_nest_depth = nil)
        if fields.key? '*'
          FullSelector.new(accepted_nest_depth)
        else
          self.new(fields, accepted_nest_depth)
        end
      end

      def initialize(fields = {}, accepted_nest_depth = nil)
        @fields = fields
        @accepted_nest_depth = accepted_nest_depth || 5
      end

      def [](name)
        if @fields[name].nil?
          DefaultSelector.new(@accepted_nest_depth - 1)
        else
          Selector.build_parsed(@fields[name], @accepted_nest_depth - 1)
        end
      end

      def canonical
        Builder.build(@fields)
      end

      def includes?(field)
        @fields.has_key?(field)
      end

      def excludes?(field)
        !@fields.has_key?('__default__') && !@fields.has_key?(field)
      end

      def eof?
        @accepted_nest_depth && @accepted_nest_depth < 0
      end
    end
  end
end
