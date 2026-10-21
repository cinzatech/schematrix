# typed: strict

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS =
      T.let(
        { "meta" => :meta, "nullable" => :nullable }.freeze,
        T::Hash[String, Symbol]
      )

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

    sig { params(value: T.untyped, klass: T.untyped).returns(T.untyped) }
    def self.coerce_class_slot(value, klass)
      if value.is_a?(klass)
        value.to_h
      elsif value.is_a?(Hash)
        klass.from_h(value)
      else
        value
      end
    end

    sig { params(value: T.untyped, klass: T.untyped).returns(T.untyped) }
    def self.coerce_array_slot(value, klass)
      return value unless value.is_a?(Array)

      value.map { |element| coerce_class_slot(element, klass) }
    end

    sig { params(value: T.untyped, klass: T.untyped).returns(T.untyped) }
    def self.coerce_map_slot(value, klass)
      return value unless value.is_a?(Hash)

      value.transform_values { |entry| coerce_class_slot(entry, klass) }
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_meta(value)
      coerce_class_slot(value, M::Schema::Defs::Meta)
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_nullable(value)
      coerce_class_slot(value, M::Schema::Defs::Nullable)
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
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

    sig { returns(T::Hash[String, T.untyped]) }
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
