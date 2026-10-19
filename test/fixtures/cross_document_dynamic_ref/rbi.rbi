# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "code" => :code }.freeze

    sig { params(code: T.nilable(String)).void }
    def initialize(code: nil)
    end

    sig { returns(T.nilable(String)) }
    def code
    end

    sig { params(code: T.nilable(String)).void }
    def code=(code)
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
