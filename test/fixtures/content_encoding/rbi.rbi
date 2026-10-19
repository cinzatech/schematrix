# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "data" => :data }.freeze

    sig { params(data: T.nilable(String)).void }
    def initialize(data: nil)
    end

    sig { returns(T.nilable(String)) }
    def data
    end

    sig { params(data: T.nilable(String)).void }
    def data=(data)
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
