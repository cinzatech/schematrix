# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "value" => :value }.freeze

    sig { params(value: T.nilable(Float)).void }
    def initialize(value: nil)
    end

    sig { returns(T.nilable(Float)) }
    def value
    end

    sig { params(value: T.nilable(Float)).void }
    def value=(value)
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
