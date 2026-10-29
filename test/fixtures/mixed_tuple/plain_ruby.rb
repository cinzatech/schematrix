require_relative "coercion_helper"

module M
  class Schema
    ORIGINAL_KEYS = { "pair" => :pair }.freeze

    def initialize(pair: nil)
      @pair = pair

      @_extra = {}
    end

    attr_accessor :pair

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.coerce_pair(value)
      ::M::CoercionHelper.coerce_spec(
        value,
        [:array, [:tuple, [nil, [:class, M::Schema::Defs::Address]], nil]]
      )
    end

    def self.from_h(hash)
      instance = new(pair: coerce_pair(hash["pair"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["pair"] = self.class.coerce_pair(@pair) unless @pair.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
