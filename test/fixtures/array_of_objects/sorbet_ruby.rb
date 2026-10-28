# typed: strict

require_relative "coercion_helper"

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS =
      T.let({ "entries" => :entries }.freeze, T::Hash[String, Symbol])

    sig do
      params(entries: T.nilable(T::Array[Schema::Props::Entries::Items])).void
    end
    def initialize(entries: nil)
      @entries = entries

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(T::Array[Schema::Props::Entries::Items])) }
    attr_accessor :entries

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_entries(value)
      ::M::CoercionHelper.coerce_spec(
        value,
        [:array, [:class, M::Schema::Props::Entries::Items]]
      )
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
    def self.from_h(hash)
      instance = new(entries: coerce_entries(hash["entries"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      result = {}
      result["entries"] = self.class.coerce_entries(
        @entries
      ) unless @entries.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
