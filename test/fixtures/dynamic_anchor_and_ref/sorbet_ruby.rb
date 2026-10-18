# typed: strict

module M
  class Schema
    sig do
      params(
        value: T.nilable(String),
        children: T.nilable(T::Array[Schema])
      ).void
    end
    def initialize(value: nil, children: nil)
      @value = value
      @children = children

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :value

    sig { params(children: T.nilable(T::Array[Schema])).void }
    attr_accessor :children

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
