# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "name" => :name, "age" => :age }.freeze

    sig { params(name: String, age: T.nilable(Integer)).void }
    def initialize(name:, age: nil)
    end

    sig { returns(String) }
    def name
    end

    sig { params(name: String).void }
    def name=(name)
    end

    sig { returns(T.nilable(Integer)) }
    def age
    end

    sig { params(age: T.nilable(Integer)).void }
    def age=(age)
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
