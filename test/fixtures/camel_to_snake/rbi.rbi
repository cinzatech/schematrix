# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = {
      "firstName" => :first_name,
      "lastName" => :last_name
    }.freeze

    sig do
      params(first_name: T.nilable(String), last_name: T.nilable(String)).void
    end
    def initialize(first_name: nil, last_name: nil)
    end

    sig { returns(T.nilable(String)) }
    def first_name
    end

    sig { params(first_name: T.nilable(String)).void }
    def first_name=(first_name)
    end

    sig { returns(T.nilable(String)) }
    def last_name
    end

    sig { params(last_name: T.nilable(String)).void }
    def last_name=(last_name)
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
