# typed: strict

module M
  class Schema
    sig { params(entries: T.nilable(T::Array[Schema::Entries::Items])).void }
    def initialize(entries: nil)
      @entries = entries

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.nilable(T::Array[Schema::Entries::Items])) }
    attr_accessor :entries

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end
  end
end
