# typed: strict

require_relative "coercion_helper"

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS = T.let({ "pair" => :pair }.freeze, T::Hash[String, Symbol])

    sig do
      params(
        pair: T.nilable(T::Array[T.any(String, Schema::Defs::Address)])
      ).void
    end
    def initialize(pair: nil)
      @pair = pair

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(T::Array[T.any(String, Schema::Defs::Address)])) }
    attr_accessor :pair

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_pair(value)
      ::M::CoercionHelper.coerce_spec(
        value,
        [:array, [:tuple, [nil, [:class, M::Schema::Defs::Address]], nil]]
      )
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
    def self.from_h(hash)
      instance = new(pair: coerce_pair(hash["pair"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      result = {}
      result["pair"] = self.class.coerce_pair(@pair) unless @pair.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
