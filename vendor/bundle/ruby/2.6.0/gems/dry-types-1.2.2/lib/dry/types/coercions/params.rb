# frozen_string_literal: true

require 'bigdecimal'
require 'bigdecimal/util'

module Dry
  module Types
    module Coercions
      # Params-specific coercions
      #
      # @api public
      module Params
        TRUE_VALUES = %w[1 on On ON t true True TRUE T y yes Yes YES Y].freeze
        FALSE_VALUES = %w[0 off Off OFF f false False FALSE F n no No NO N].freeze
        BOOLEAN_MAP = ::Hash[
          TRUE_VALUES.product([true]) + FALSE_VALUES.product([false])
        ].merge(true => true, false => false).freeze

        extend Coercions

        # @param [String, Object] input
        #
        # @return [Boolean,Object]
        #
        # @see TRUE_VALUES
        # @see FALSE_VALUES
        #
        # @raise CoercionError
        #
        # @api public
        def self.to_true(input, &_block)
          BOOLEAN_MAP.fetch(input.to_s) do
            if block_given?
              yield
            else
              raise CoercionError, "#{input} cannot be coerced to true"
            end
          end
        end

        # @param [String, Object] input
        #
        # @return [Boolean,Object]
        #
        # @see TRUE_VALUES
        # @see FALSE_VALUES
        #
        # @raise CoercionError
        #
        # @api public
        def self.to_false(input, &_block)
          BOOLEAN_MAP.fetch(input.to_s) do
            if block_given?
              yield
            else
              raise CoercionError, "#{input} cannot be coerced to false"
            end
          end
        end

        # @param [#to_int, #to_i, Object] input
        #
        # @return [Integer, nil, Object]
        #
        # @raise CoercionError
        #
        # @api public
        def self.to_int(input, &block)
          if input.is_a? String
            Integer(input, 10)
          else
            Integer(input)
          end
        rescue ArgumentError, TypeError => e
          CoercionError.handle(e, &block)
        end

        # @param [#to_f, Object] input
        #
        # @return [Float, nil, Object]
        #
        # @raise CoercionError
        #
        # @api public
        def self.to_float(input, &block)
          Float(input)
        rescue ArgumentError, TypeError => e
          CoercionError.handle(e, &block)
        end

        # @param [#to_d, Object] input
        #
        # @return [BigDecimal, nil, Object]
        #
        # @raise CoercionError
        #
        # @api public
        def self.to_decimal(input, &block)
          to_float(input) do
            if block_given?
              return yield
            else
              raise CoercionError, "#{input.inspect} cannot be coerced to decimal"
            end
          end

          input.to_d
        end

        # @param [Array, String, Object] input
        #
        # @return [Array, Object]
        #
        # @raise CoercionError
        #
        # @api public
        def self.to_ary(input, &_block)
          if empty_str?(input)
            []
          elsif input.is_a?(::Array)
            input
          elsif block_given?
            yield
          else
            raise CoercionError, "#{input.inspect} cannot be coerced to array"
          end
        end

        # @param [Hash, String, Object] input
        #
        # @return [Hash, Object]
        #
        # @raise CoercionError
        #
        # @api public
        def self.to_hash(input, &_block)
          if empty_str?(input)
            {}
          elsif input.is_a?(::Hash)
            input
          elsif block_given?
            yield
          else
            raise CoercionError, "#{input.inspect} cannot be coerced to hash"
          end
        end
      end
    end
  end
end
