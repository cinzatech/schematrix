# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "tagged" => :tagged }.freeze

    sig do
      params(
        tagged: T.nilable(T::Array[T.any(String, Schema::Defs::Address)])
      ).void
    end
    def initialize(tagged: nil)
    end

    sig { returns(T.nilable(T::Array[T.any(String, Schema::Defs::Address)])) }
    def tagged
    end

    sig do
      params(
        tagged: T.nilable(T::Array[T.any(String, Schema::Defs::Address)])
      ).void
    end
    def tagged=(tagged)
    end

    sig { params(key: String).returns(T.anything) }
    def [](key)
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_tagged(value)
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
    end
  end
end
