# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "meta" => :meta }.freeze

    sig { params(meta: T.nilable(T.any(Schema::Props::Meta, T::Boolean))).void }
    def initialize(meta: nil)
    end

    sig { returns(T.nilable(T.any(Schema::Props::Meta, T::Boolean))) }
    def meta
    end

    sig { params(meta: T.nilable(T.any(Schema::Props::Meta, T::Boolean))).void }
    def meta=(meta)
    end

    sig { params(key: String).returns(T.anything) }
    def [](key)
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end

    sig { params(value: T.anything, klass: T.anything).returns(T.anything) }
    def self.coerce_class_slot(value, klass)
    end

    sig { params(value: T.anything, spec: T.anything).returns(T.anything) }
    def self.coerce_spec(value, spec)
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_meta(value)
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
    end
  end
end
