# typed: strict

require_relative "coercion_helper"

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS =
      T.let({ "address" => :address }.freeze, T::Hash[String, Symbol])

    sig { params(address: T.nilable(Schema::Defs::Address)).void }
    def initialize(address: nil)
      @address = address

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(Schema::Defs::Address)) }
    attr_accessor :address

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_address(value)
      ::M::CoercionHelper.coerce_spec(value, [:class, M::Schema::Defs::Address])
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
    def self.from_h(hash)
      instance = new(address: coerce_address(hash["address"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      result = {}
      result["address"] = self.class.coerce_address(
        @address
      ) unless @address.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
