require_relative "coercion_helper"

module M
  class Schema
    ORIGINAL_KEYS = { "meta" => :meta, "nullable" => :nullable }.freeze

    def initialize(meta: nil, nullable: nil)
      @meta = meta
      @nullable = nullable

      @_extra = {}
    end

    attr_accessor :meta, :nullable

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.coerce_meta(value)
      ::M::CoercionHelper.coerce_spec(value, [:class, M::Schema::Defs::Meta])
    end

    def self.coerce_nullable(value)
      ::M::CoercionHelper.coerce_spec(
        value,
        [:class, M::Schema::Defs::Nullable]
      )
    end

    def self.from_h(hash)
      instance =
        new(
          meta: coerce_meta(hash["meta"]),
          nullable: coerce_nullable(hash["nullable"])
        )

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["meta"] = self.class.coerce_meta(@meta) unless @meta.nil?
      result["nullable"] = self.class.coerce_nullable(
        @nullable
      ) unless @nullable.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
