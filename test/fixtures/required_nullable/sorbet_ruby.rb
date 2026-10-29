# typed: strict

require_relative "coercion_helper"

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS =
      T.let(
        { "name" => :name, "child" => :child }.freeze,
        T::Hash[String, Symbol]
      )

    sig do
      params(
        name: T.nilable(String),
        child: T.nilable(Schema::Props::Child)
      ).void
    end
    def initialize(name:, child: nil)
      @name = name
      @child = child

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :name

    sig { returns(T.nilable(Schema::Props::Child)) }
    attr_accessor :child

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_child(value)
      ::M::CoercionHelper.coerce_spec(value, [:class, M::Schema::Props::Child])
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
    def self.from_h(hash)
      instance = new(name: hash["name"], child: coerce_child(hash["child"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      result = {}
      result["name"] = @name unless @name.nil?
      result["child"] = self.class.coerce_child(@child) unless @child.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
