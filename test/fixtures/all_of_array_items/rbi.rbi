# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "values" => :values }.freeze

    sig { params(values: T.nilable(T::Array[T.all(String, Integer)])).void }
    def initialize(values: nil)
    end

    sig { returns(T.nilable(T::Array[T.all(String, Integer)])) }
    def values
    end

    sig { params(values: T.nilable(T::Array[T.all(String, Integer)])).void }
    def values=(values)
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
