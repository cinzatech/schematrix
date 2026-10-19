# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "meta" => :meta, "nullable" => :nullable }.freeze

    sig do
      params(
        meta: T.nilable(T.any(T::Boolean, Schema::Defs::Meta)),
        nullable: T.nilable(Schema::Defs::Nullable)
      ).void
    end
    def initialize(meta: nil, nullable: nil)
      @meta = meta
      @nullable = nullable

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(T.any(T::Boolean, Schema::Defs::Meta))) }
    attr_accessor :meta

    sig { returns(T.nilable(Schema::Defs::Nullable)) }
    attr_accessor :nullable

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_meta(value)
      if value.is_a?(M::Schema::Defs::Meta)
        value.to_h
      elsif value.is_a?(Hash)
        M::Schema::Defs::Meta.from_h(value)
      else
        value
      end
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_nullable(value)
      if value.is_a?(M::Schema::Defs::Nullable)
        value.to_h
      elsif value.is_a?(Hash)
        M::Schema::Defs::Nullable.from_h(value)
      else
        value
      end
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
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

    sig { returns(T::Hash[String, T.anything]) }
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
