require_relative "coercion_helper"

module M
  class Schema
    ORIGINAL_KEYS = { "owner" => :owner }.freeze

    def initialize(owner: nil)
      @owner = owner

      @_extra = {}
    end

    attr_accessor :owner

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.coerce_owner(value)
      ::M::CoercionHelper.coerce_spec(value, [:class, M::Schema::Defs::Named])
    end

    def self.from_h(hash)
      instance = new(owner: coerce_owner(hash["owner"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["owner"] = self.class.coerce_owner(@owner) unless @owner.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
