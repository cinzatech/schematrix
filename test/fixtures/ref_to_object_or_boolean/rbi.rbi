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
    end

    sig { returns(T.nilable(T.any(T::Boolean, Schema::Defs::Meta))) }
    def meta
    end

    sig { params(meta: T.nilable(T.any(T::Boolean, Schema::Defs::Meta))).void }
    def meta=(meta)
    end

    sig { returns(T.nilable(Schema::Defs::Nullable)) }
    def nullable
    end

    sig { params(nullable: T.nilable(Schema::Defs::Nullable)).void }
    def nullable=(nullable)
    end

    sig { params(key: String).returns(T.anything) }
    def [](key)
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_meta(value)
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_nullable(value)
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
    end
  end
end
