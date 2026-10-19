# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = {
      "name" => :name,
      "age" => :age,
      "active" => :active
    }.freeze

    sig do
      params(
        name: T.nilable(String),
        age: T.nilable(Integer),
        active: T.nilable(T::Boolean)
      ).void
    end
    def initialize(name: nil, age: nil, active: nil)
    end

    sig { returns(T.nilable(String)) }
    def name
    end

    sig { params(name: T.nilable(String)).void }
    def name=(name)
    end

    sig { returns(T.nilable(Integer)) }
    def age
    end

    sig { params(age: T.nilable(Integer)).void }
    def age=(age)
    end

    sig { returns(T.nilable(T::Boolean)) }
    def active
    end

    sig { params(active: T.nilable(T::Boolean)).void }
    def active=(active)
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
