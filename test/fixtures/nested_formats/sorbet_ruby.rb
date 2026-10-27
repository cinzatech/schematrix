# typed: strict

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS =
      T.let(
        {
          "log" => :log,
          "window" => :window,
          "rates" => :rates,
          "milestone" => :milestone,
          "amount" => :amount
        }.freeze,
        T::Hash[String, Symbol]
      )

    sig do
      params(
        log: T.nilable(T::Array[Time]),
        window: T.nilable(T::Array[T.any(Date, Time)]),
        rates: T.nilable(T::Hash[String, Time]),
        milestone: T.nilable(T.any(Date, Integer)),
        amount: T.nilable(T.any(Time, Schema::Defs::Money))
      ).void
    end
    def initialize(
      log: nil,
      window: nil,
      rates: nil,
      milestone: nil,
      amount: nil
    )
      @log = log
      @window = window
      @rates = rates
      @milestone = milestone
      @amount = amount

      @_extra = T.let({}, T::Hash[String, T.nilable(Date)])
    end

    sig { returns(T.nilable(T::Array[Time])) }
    attr_accessor :log

    sig { returns(T.nilable(T::Array[T.any(Date, Time)])) }
    attr_accessor :window

    sig { returns(T.nilable(T::Hash[String, Time])) }
    attr_accessor :rates

    sig { returns(T.nilable(T.any(Date, Integer))) }
    attr_accessor :milestone

    sig { returns(T.nilable(T.any(Time, Schema::Defs::Money))) }
    attr_accessor :amount

    sig { params(key: String).returns(T.nilable(Date)) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.nilable(Date)).returns(T.nilable(Date)) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(value: T.untyped, klass: T.untyped).returns(T.untyped) }
    def self.coerce_class_slot(value, klass)
      if value.is_a?(klass)
        value.to_h
      elsif value.is_a?(Hash)
        klass.from_h(value)
      else
        value
      end
    end

    sig { params(value: T.untyped, spec: T.untyped).returns(T.untyped) }
    def self.coerce_spec(value, spec)
      case spec[0]
      when :coerce
        spec[1].coerce(value)
      when :class
        coerce_class_slot(value, spec[1])
      when :array
        return value unless value.is_a?(Array)

        if spec[1][0] == :tuple
          prefix, tail = spec[1][1], spec[1][2]
          value.each_with_index.map do |element, index|
            sub = index < prefix.size ? prefix[index] : tail
            sub.nil? ? element : coerce_spec(element, sub)
          end
        else
          value.map { |element| coerce_spec(element, spec[1]) }
        end
      when :map
        return value unless value.is_a?(Hash)

        value.transform_values { |entry| coerce_spec(entry, spec[1]) }
      when :union
        result = value
        spec[1].each do |sub|
          case sub[0]
          when :class
            result = coerce_class_slot(result, sub[1])
          when :array
            if result.is_a?(Array)
              result = result.map { |element| coerce_spec(element, sub[1]) }
            end
          when :map
            if result.is_a?(Hash)
              result =
                result.transform_values { |entry| coerce_spec(entry, sub[1]) }
            end
          when :coerce
            result = sub[1].coerce(result)
          end
        end
        result
      end
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_extra(value)
      coerce_spec(value, [:coerce, ::M::Schematrix::Coercers::Date])
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_log(value)
      coerce_spec(
        value,
        [:array, [:coerce, ::M::Schematrix::Coercers::DateTime]]
      )
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_window(value)
      coerce_spec(
        value,
        [
          :array,
          [
            :tuple,
            [
              [:coerce, ::M::Schematrix::Coercers::Date],
              [:coerce, ::M::Schematrix::Coercers::DateTime]
            ],
            nil
          ]
        ]
      )
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_rates(value)
      coerce_spec(value, [:map, [:coerce, ::M::Schematrix::Coercers::DateTime]])
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_milestone(value)
      ::M::Schematrix::Coercers::Date.coerce(value)
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_amount(value)
      coerce_spec(
        value,
        [
          :union,
          [
            [:class, M::Schema::Defs::Money],
            [:coerce, ::M::Schematrix::Coercers::DateTime]
          ]
        ]
      )
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
    def self.from_h(hash)
      instance =
        new(
          log: coerce_log(hash["log"]),
          window: coerce_window(hash["window"]),
          rates: coerce_rates(hash["rates"]),
          milestone: coerce_milestone(hash["milestone"]),
          amount: coerce_amount(hash["amount"])
        )

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = coerce_extra(value)
      end
      instance
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      result = {}
      result["log"] = self.class.coerce_log(@log) unless @log.nil?
      result["window"] = self.class.coerce_window(@window) unless @window.nil?
      result["rates"] = self.class.coerce_rates(@rates) unless @rates.nil?
      result["milestone"] = self.class.coerce_milestone(
        @milestone
      ) unless @milestone.nil?
      result["amount"] = self.class.coerce_amount(@amount) unless @amount.nil?
      @_extra.each { |key, value| result[key] = self.class.coerce_extra(value) }
      result
    end
  end

  module Schematrix
    module Coercers
      module DateTime
        require "time"

        sig { params(value: T.untyped).returns(T.untyped) }
        def self.coerce(value)
          case value
          when String
            ::Time.iso8601(value)
          when ::Time
            value.iso8601
          else
            value
          end
        end
      end

      module Date
        require "date"

        sig { params(value: T.untyped).returns(T.untyped) }
        def self.coerce(value)
          case value
          when String
            ::Date.iso8601(value)
          when ::Date
            value.iso8601
          else
            value
          end
        end
      end
    end
  end
end
