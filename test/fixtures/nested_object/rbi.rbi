# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "child" => :child }.freeze

    sig { params(child: T.nilable(Schema::Props::Child)).void }
    def initialize(child: nil)
    end

    sig { returns(T.nilable(Schema::Props::Child)) }
    def child
    end

    sig { params(child: T.nilable(Schema::Props::Child)).void }
    def child=(child)
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
    def self.coerce_child(value)
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
    end
  end
end
