# typed: strict

module M
  class Schema::L1::L2
    sig { params(val: T.nilable(String)).void }
    def initialize(val: nil)
      @val = val

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :val

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
