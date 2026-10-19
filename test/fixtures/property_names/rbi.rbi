# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "vocab" => :vocab }.freeze

    sig { params(vocab: T.nilable(T::Hash[String, T::Boolean])).void }
    def initialize(vocab: nil)
    end

    sig { returns(T.nilable(T::Hash[String, T::Boolean])) }
    def vocab
    end

    sig { params(vocab: T.nilable(T::Hash[String, T::Boolean])).void }
    def vocab=(vocab)
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
