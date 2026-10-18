# typed: strict

module M
  class Schema
    sig { params(entries: T.nilable(T::Array[Schema::Entries::Items])).void }
    def initialize(entries: nil)
    end

    sig { returns(T.nilable(T::Array[Schema::Entries::Items])) }
    def entries
    end

    sig { params(entries: T.nilable(T::Array[Schema::Entries::Items])).void }
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
