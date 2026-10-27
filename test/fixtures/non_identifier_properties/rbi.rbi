# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "first name" => :first_name, "a/b" => :a_b }.freeze

    sig do
      params(
        first_name: T.nilable(Schema::Props::FirstName),
        a_b: T.nilable(Schema::Props::AB)
      ).void
    end
    def initialize(first_name: nil, a_b: nil)
    end

    sig { returns(T.nilable(Schema::Props::FirstName)) }
    def first_name
    end

    sig { params(first_name: T.nilable(Schema::Props::FirstName)).void }
    def first_name=(first_name)
    end

    sig { returns(T.nilable(Schema::Props::AB)) }
    def a_b
    end

    sig { params(a_b: T.nilable(Schema::Props::AB)).void }
    def a_b=(a_b)
    end

    sig { params(key: String).returns(T.anything) }
    def [](key)
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end

    sig { params(value: T.anything, klass: T.anything).returns(T.anything) }
    def self.coerce_class_slot(value, klass)
    end

    sig { params(value: T.anything, spec: T.anything).returns(T.anything) }
    def self.coerce_spec(value, spec)
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_first_name(value)
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_a_b(value)
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
    end
  end
end
