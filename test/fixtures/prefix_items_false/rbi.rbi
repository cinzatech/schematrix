# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "flags" => :flags }.freeze

    sig { params(flags: T.nilable(T::Array[String])).void }
    def initialize(flags: nil)
    end

    sig { returns(T.nilable(T::Array[String])) }
    def flags
    end

    sig { params(flags: T.nilable(T::Array[String])).void }
    def flags=(flags)
    end

    sig { params(key: String).returns(T.anything) }
    def [](key)
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
    end
  end
end
