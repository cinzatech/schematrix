# typed: strict

module M
  class Schema
    sig { params(color: T.nilable(String), count: T.nilable(Integer)).void }
    def initialize(color: "blue", count: 0)
      @color = color
      @count = count

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :color

    sig { returns(T.nilable(Integer)) }
    attr_accessor :count

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
