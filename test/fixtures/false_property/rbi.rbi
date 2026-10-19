# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "name" => :name, "legacy" => :legacy }.freeze

    sig { params(name: T.nilable(String), legacy: T.nilable(T.noreturn)).void }
    def initialize(name: nil, legacy: nil)
    end

    sig { returns(T.nilable(String)) }
    def name
    end

    sig { params(name: T.nilable(String)).void }
    def name=(name)
    end

    sig { returns(T.nilable(T.noreturn)) }
    def legacy
    end

    sig { params(legacy: T.nilable(T.noreturn)).void }
    def legacy=(legacy)
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
