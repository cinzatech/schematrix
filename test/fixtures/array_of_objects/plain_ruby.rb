require_relative "coercion_helper"

module M
  class Schema
    ORIGINAL_KEYS = { "entries" => :entries }.freeze

    def initialize(entries: nil)
      @entries = entries

      @_extra = {}
    end

    attr_accessor :entries

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.coerce_entries(value)
      ::M::CoercionHelper.coerce_spec(
        value,
        [:array, [:class, M::Schema::Props::Entries::Items]]
      )
    end

    def self.from_h(hash)
      instance = new(entries: coerce_entries(hash["entries"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["entries"] = self.class.coerce_entries(
        @entries
      ) unless @entries.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
