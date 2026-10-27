# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "address" => :address }.freeze

    sig { params(address: T.nilable(Schema::Defs::Address)).void }
    def initialize(address: nil)
    end

    sig { returns(T.nilable(Schema::Defs::Address)) }
    def address
    end

    sig { params(address: T.nilable(Schema::Defs::Address)).void }
    def address=(address)
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
    def self.coerce_address(value)
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
    end
  end
end
