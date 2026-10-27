# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "value" => :value }.freeze

    sig { params(value: T.nilable(T.any(Schema::Defs::Named, String))).void }
    def initialize(value: nil)
    end

    sig { returns(T.nilable(T.any(Schema::Defs::Named, String))) }
    def value
    end

    sig { params(value: T.nilable(T.any(Schema::Defs::Named, String))).void }
    def value=(value)
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
    def self.coerce_value(value)
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
    end
  end
end
