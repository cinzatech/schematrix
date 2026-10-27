# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "value" => :value, "children" => :children }.freeze

    sig do
      params(
        value: T.nilable(String),
        children: T.nilable(T::Array[Schema])
      ).void
    end
    def initialize(value: nil, children: nil)
    end

    sig { returns(T.nilable(String)) }
    def value
    end

    sig { params(value: T.nilable(String)).void }
    def value=(value)
    end

    sig { returns(T.nilable(T::Array[Schema])) }
    def children
    end

    sig { params(children: T.nilable(T::Array[Schema])).void }
    def children=(children)
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
    def self.coerce_children(value)
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
    end
  end
end
