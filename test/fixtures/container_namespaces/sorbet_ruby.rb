# typed: strict

require_relative "coercion_helper"

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS =
      T.let({ "home" => :home, "alt" => :alt }.freeze, T::Hash[String, Symbol])

    sig do
      params(
        home: T.nilable(Schema::Props::Home),
        alt: T.nilable(Schema::Defs::Address)
      ).void
    end
    def initialize(home: nil, alt: nil)
      @home = home
      @alt = alt

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(Schema::Props::Home)) }
    attr_accessor :home

    sig { returns(T.nilable(Schema::Defs::Address)) }
    attr_accessor :alt

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_home(value)
      ::M::CoercionHelper.coerce_spec(value, [:class, M::Schema::Props::Home])
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_alt(value)
      ::M::CoercionHelper.coerce_spec(value, [:class, M::Schema::Defs::Address])
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
    def self.from_h(hash)
      instance =
        new(home: coerce_home(hash["home"]), alt: coerce_alt(hash["alt"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      result = {}
      result["home"] = self.class.coerce_home(@home) unless @home.nil?
      result["alt"] = self.class.coerce_alt(@alt) unless @alt.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
