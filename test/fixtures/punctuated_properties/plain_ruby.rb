require_relative "coercion_helper"

module M
  class Schema
    ORIGINAL_KEYS = {
      "example.com" => :example_com,
      "web.hook" => :web_hook
    }.freeze

    def initialize(example_com: nil, web_hook: nil)
      @example_com = example_com
      @web_hook = web_hook

      @_extra = {}
    end

    attr_accessor :example_com, :web_hook

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.coerce_web_hook(value)
      ::M::CoercionHelper.coerce_spec(
        value,
        [:class, M::Schema::Props::WebHook]
      )
    end

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
