# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "always" => :always }.freeze

    sig { params(always: T.nilable(T::Boolean)).void }
    def initialize(always: nil)
    end

    sig { returns(T.nilable(T::Boolean)) }
    def always
    end

    sig { params(always: T.nilable(T::Boolean)).void }
    def always=(always)
    end

    sig do
      params(key: String).returns(T.nilable(T.any(String, Schema::Defs::Thing)))
    end
    def [](key)
    end

    sig do
      params(
        key: String,
        value: T.nilable(T.any(String, Schema::Defs::Thing))
      ).returns(T.nilable(T.any(String, Schema::Defs::Thing)))
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
