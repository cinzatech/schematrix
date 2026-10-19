# typed: strict

module M
  class Schema
    sig { params(tags: T.nilable(T::Hash[String, String])).void }
    def initialize(tags: nil)
      @tags = tags

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.nilable(T::Hash[String, String])) }
    attr_accessor :tags

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
