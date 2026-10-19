# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "point" => :point }.freeze

    sig { params(point: T.nilable(T::Array[Numeric])).void }
    def initialize(point: nil)
    end

    sig { returns(T.nilable(T::Array[Numeric])) }
    def point
    end

    sig { params(point: T.nilable(T::Array[Numeric])).void }
    def point=(point)
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
