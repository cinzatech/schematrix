# typed: strict

require_relative "coercion_helper"

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS =
      T.let({ "tagged" => :tagged }.freeze, T::Hash[String, Symbol])

    sig do
      params(
        tagged: T.nilable(T::Array[T.any(String, Schema::Defs::Address)])
      ).void
    end
    def initialize(tagged: nil)
      @tagged = tagged

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(T::Array[T.any(String, Schema::Defs::Address)])) }
    attr_accessor :tagged

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_tagged(value)
      ::M::CoercionHelper.coerce_spec(
        value,
        [:array, [:tuple, [nil], [:class, M::Schema::Defs::Address]]]
      )
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
    def self.from_h(hash)
      instance = new(tagged: coerce_tagged(hash["tagged"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      result = {}
      result["tagged"] = self.class.coerce_tagged(@tagged) unless @tagged.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
