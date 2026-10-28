# typed: strict

require_relative "coercion_helper"

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS =
      T.let(
        { "example.com" => :example_com, "web.hook" => :web_hook }.freeze,
        T::Hash[String, Symbol]
      )

    sig do
      params(
        example_com: T.nilable(String),
        web_hook: T.nilable(Schema::Props::WebHook)
      ).void
    end
    def initialize(example_com: nil, web_hook: nil)
      @example_com = example_com
      @web_hook = web_hook

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :example_com

    sig { returns(T.nilable(Schema::Props::WebHook)) }
    attr_accessor :web_hook

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_web_hook(value)
      ::M::CoercionHelper.coerce_spec(
        value,
        [:class, M::Schema::Props::WebHook]
      )
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
    def self.from_h(hash)
      instance =
        new(
          example_com: hash["example.com"],
          web_hook: coerce_web_hook(hash["web.hook"])
        )

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      result = {}
      result["example.com"] = @example_com unless @example_com.nil?
      result["web.hook"] = self.class.coerce_web_hook(
        @web_hook
      ) unless @web_hook.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
