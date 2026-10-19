# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "email" => :email }.freeze

    sig { params(email: T.nilable(String)).void }
    def initialize(email: nil)
    end

    sig { returns(T.nilable(String)) }
    def email
    end

    sig { params(email: T.nilable(String)).void }
    def email=(email)
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
