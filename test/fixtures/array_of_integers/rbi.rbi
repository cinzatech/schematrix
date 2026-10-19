# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "scores" => :scores }.freeze

    sig { params(scores: T.nilable(T::Array[Integer])).void }
    def initialize(scores: nil)
    end

    sig { returns(T.nilable(T::Array[Integer])) }
    def scores
    end

    sig { params(scores: T.nilable(T::Array[Integer])).void }
    def scores=(scores)
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
