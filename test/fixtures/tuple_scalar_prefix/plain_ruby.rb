require_relative "coercion_helper"

module M
  class Schema
    ORIGINAL_KEYS = { "tagged" => :tagged }.freeze

    def initialize(tagged: nil)
      @tagged = tagged

      @_extra = {}
    end

    attr_accessor :tagged

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.coerce_tagged(value)
      ::M::CoercionHelper.coerce_spec(
        value,
        [:array, [:tuple, [nil], [:class, M::Schema::Defs::Address]]]
      )
    end

    def self.from_h(hash)
      instance = new(tagged: coerce_tagged(hash["tagged"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["tagged"] = self.class.coerce_tagged(@tagged) unless @tagged.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
