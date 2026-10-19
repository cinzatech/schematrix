# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "name" => :name, "code" => :code }.freeze

    sig { params(name: T.nilable(String), code: T.nilable(String)).void }
    def initialize(name: nil, code: nil)
    end

    sig { returns(T.nilable(String)) }
    def name
    end

    sig { params(name: T.nilable(String)).void }
    def name=(name)
    end

    sig { returns(T.nilable(String)) }
    def code
    end

    sig { params(code: T.nilable(String)).void }
    def code=(code)
    end

    sig { params(key: String).returns(T.nilable(Float)) }
    def [](key)
    end

    sig do
      params(key: String, value: T.nilable(Float)).returns(T.nilable(Float))
    end
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
