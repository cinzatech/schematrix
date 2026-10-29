# typed: strict

require_relative "coercion_helper"

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS = T.let({ "vars" => :vars }.freeze, T::Hash[String, Symbol])

    sig { params(vars: T.nilable(T::Hash[String, Schema::Defs::Value])).void }
    def initialize(vars: nil)
      @vars = vars

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(T::Hash[String, Schema::Defs::Value])) }
    attr_accessor :vars

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_vars(value)
      ::M::CoercionHelper.coerce_spec(
        value,
        [:map, [:class, M::Schema::Defs::Value]]
      )
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
    def self.from_h(hash)
      instance = new(vars: coerce_vars(hash["vars"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      result = {}
      result["vars"] = self.class.coerce_vars(@vars) unless @vars.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
