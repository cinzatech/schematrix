require_relative "coercion_helper"

module M
  class Schema
    ORIGINAL_KEYS = { "first name" => :first_name, "a/b" => :a_b }.freeze

    def initialize(first_name: nil, a_b: nil)
      @first_name = first_name
      @a_b = a_b

      @_extra = {}
    end

    attr_accessor :first_name, :a_b

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.coerce_first_name(value)
      ::M::CoercionHelper.coerce_spec(
        value,
        [:class, M::Schema::Props::FirstName]
      )
    end

    def self.coerce_a_b(value)
      ::M::CoercionHelper.coerce_spec(value, [:class, M::Schema::Props::AB])
    end

    def self.from_h(hash)
      instance =
        new(
          first_name: coerce_first_name(hash["first name"]),
          a_b: coerce_a_b(hash["a/b"])
        )

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["first name"] = self.class.coerce_first_name(
        @first_name
      ) unless @first_name.nil?
      result["a/b"] = self.class.coerce_a_b(@a_b) unless @a_b.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
