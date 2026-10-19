# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "a" => :a }.freeze

    sig { params(a: T.nilable(T.all(String, Integer))).void }
    def initialize(a: nil)
    end

    sig { returns(T.nilable(T.all(String, Integer))) }
    def a
    end

    sig { params(a: T.nilable(T.all(String, Integer))).void }
    def a=(a)
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
