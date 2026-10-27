# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "entries" => :entries }.freeze

    sig do
      params(entries: T.nilable(T::Array[Schema::Props::Entries::Items])).void
    end
    def initialize(entries: nil)
    end

    sig { returns(T.nilable(T::Array[Schema::Props::Entries::Items])) }
    def entries
    end

    sig do
      params(entries: T.nilable(T::Array[Schema::Props::Entries::Items])).void
    end
    def entries=(entries)
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
    def self.coerce_entries(value)
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
    end
  end
end
