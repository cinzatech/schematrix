# typed: strict

require_relative "coercion_helper"

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS = T.let({ "owner" => :owner }.freeze, T::Hash[String, Symbol])

    sig { params(owner: T.nilable(Schema::Defs::Named)).void }
    def initialize(owner: nil)
      @owner = owner

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(Schema::Defs::Named)) }
    attr_accessor :owner

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_owner(value)
      ::M::CoercionHelper.coerce_spec(value, [:class, M::Schema::Defs::Named])
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
    def self.from_h(hash)
      instance = new(owner: coerce_owner(hash["owner"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      result = {}
      result["owner"] = self.class.coerce_owner(@owner) unless @owner.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
