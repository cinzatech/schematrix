# typed: strict

module M
  class Schema
    sig { params(vocab: T.nilable(T::Hash[String, T::Boolean])).void }
    def initialize(vocab: nil)
      @vocab = vocab

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.nilable(T::Hash[String, T::Boolean])) }
    attr_accessor :vocab

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
