# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "items" => :items }.freeze

    sig { params(items: T.nilable(T::Array[String])).void }
    def initialize(items: nil)
    end

    sig { returns(T.nilable(T::Array[String])) }
    def items
    end

    sig { params(items: T.nilable(T::Array[String])).void }
    def items=(items)
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
