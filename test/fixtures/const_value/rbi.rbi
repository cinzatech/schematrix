# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "status" => :status }.freeze

    sig { params(status: T.nilable(String)).void }
    def initialize(status: nil)
    end

    sig { returns(T.nilable(String)) }
    def status
    end

    sig { params(status: T.nilable(String)).void }
    def status=(status)
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
