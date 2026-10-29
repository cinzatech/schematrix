# typed: strict

require_relative "coercion_helper"

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS =
      T.let(
        { "value" => :value, "children" => :children }.freeze,
        T::Hash[String, Symbol]
      )

    sig do
      params(
        value: T.nilable(String),
        children: T.nilable(T::Array[Schema])
      ).void
    end
    def initialize(value: nil, children: nil)
      @value = value
      @children = children

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :value

    sig { returns(T.nilable(T::Array[Schema])) }
    attr_accessor :children

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_children(value)
      ::M::CoercionHelper.coerce_spec(value, [:array, [:class, M::Schema]])
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
    def self.from_h(hash)
      instance =
        new(value: hash["value"], children: coerce_children(hash["children"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      result = {}
      result["value"] = @value unless @value.nil?
      result["children"] = self.class.coerce_children(
        @children
      ) unless @children.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
