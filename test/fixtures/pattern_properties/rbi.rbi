# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "config" => :config }.freeze

    sig { params(config: T.nilable(T::Hash[String, T.anything])).void }
    def initialize(config: nil)
    end

    sig { returns(T.nilable(T::Hash[String, T.anything])) }
    def config
    end

    sig { params(config: T.nilable(T::Hash[String, T.anything])).void }
    def config=(config)
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
