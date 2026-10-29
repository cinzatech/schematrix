require_relative "coercion_helper"

module M
  class Schema
    ORIGINAL_KEYS = { "vars" => :vars }.freeze

    def initialize(vars: nil)
      @vars = vars

      @_extra = {}
    end

    attr_accessor :vars

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.coerce_vars(value)
      ::M::CoercionHelper.coerce_spec(
        value,
        [:map, [:class, M::Schema::Defs::Value]]
      )
    end

    def self.from_h(hash)
      instance = new(vars: coerce_vars(hash["vars"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["vars"] = self.class.coerce_vars(@vars) unless @vars.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
