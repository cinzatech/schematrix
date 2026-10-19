# typed: strict

module M
  class Schema
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

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
