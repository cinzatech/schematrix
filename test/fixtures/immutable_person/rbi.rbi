# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = {
      "firstName" => :first_name,
      "lastName" => :last_name,
      "age" => :age,
      "color" => :color
    }.freeze

    sig do
      params(
        first_name: String,
        last_name: String,
        age: T.nilable(Integer),
        color: T.nilable(String),
        _extra: T::Hash[String, T.anything]
      ).void
    end
    def initialize(first_name:, last_name:, age: nil, color: "blue", _extra: {})
    end

    sig { returns(String) }
    def first_name
    end

    sig { returns(String) }
    def last_name
    end

    sig { returns(T.nilable(Integer)) }
    def age
    end

    sig { returns(T.nilable(String)) }
    def color
    end

    sig { params(key: String).returns(T.anything) }
    def [](key)
    end

    sig do
      params(
        first_name: String,
        last_name: String,
        age: T.nilable(Integer),
        color: T.nilable(String),
        _extra: T::Hash[String, T.anything]
      ).returns(T.self_type)
    end
    def with(
      first_name: T.untyped,
      last_name: T.untyped,
      age: T.untyped,
      color: T.untyped,
      _extra: T.untyped
    )
    end

    sig { params(other: T.anything).returns(T::Boolean) }
    def ==(other)
    end

    alias eql? ==

    sig { returns(Integer) }
    def hash
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
    end

    protected

    sig { returns(T::Hash[String, T.anything]) }
    def _extra
    end
  end
end
