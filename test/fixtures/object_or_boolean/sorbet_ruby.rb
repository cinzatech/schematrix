# typed: strict

require_relative "coercion_helper"

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS = T.let({ "meta" => :meta }.freeze, T::Hash[String, Symbol])

    sig { params(meta: T.nilable(T.any(Schema::Props::Meta, T::Boolean))).void }
    def initialize(meta: nil)
      @meta = meta

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(T.any(Schema::Props::Meta, T::Boolean))) }
    attr_accessor :meta

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_meta(value)
      ::M::CoercionHelper.coerce_spec(value, [:class, M::Schema::Props::Meta])
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
    def self.from_h(hash)
      instance = new(meta: coerce_meta(hash["meta"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      result = {}
      result["meta"] = self.class.coerce_meta(@meta) unless @meta.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
