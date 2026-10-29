# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = {
      "firstName" => :first_name,
      "age" => :age,
      "tag" => :tag,
      "address" => :address
    }.freeze

    sig do
      params(
        first_name: String,
        age: Maybe[Integer],
        tag: Maybe[String],
        address: Maybe[Schema::Props::Address]
      ).void
    end
    def initialize(
      first_name:,
      age: Maybe.empty,
      tag: Maybe.from("none"),
      address: Maybe.empty
    )
    end

    sig { returns(String) }
    def first_name
    end

    sig { params(first_name: String).void }
    def first_name=(first_name)
    end

    sig { returns(Maybe[Integer]) }
    def age
    end

    sig { params(age: Maybe[Integer]).void }
    def age=(age)
    end

    sig { returns(Maybe[String]) }
    def tag
    end

    sig { params(tag: Maybe[String]).void }
    def tag=(tag)
    end

    sig { returns(Maybe[Schema::Props::Address]) }
    def address
    end

    sig { params(address: Maybe[Schema::Props::Address]).void }
    def address=(address)
    end

    sig { params(key: String).returns(T.anything) }
    def [](key)
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_address(value)
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
    end
  end
end
