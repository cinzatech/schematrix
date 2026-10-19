# typed: strict

module M
  class Schema
    sig do
      params(
        flag: T.anything,
        dead: T.nilable(T.noreturn),
        sibling: T.nilable(String)
      ).void
    end
    def initialize(flag: nil, dead: nil, sibling: nil)
      @flag = flag
      @dead = dead
      @sibling = sibling

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.anything) }
    attr_accessor :flag

    sig { returns(T.nilable(T.noreturn)) }
    attr_accessor :dead

    sig { returns(T.nilable(String)) }
    attr_accessor :sibling

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
