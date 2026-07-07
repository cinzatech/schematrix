# typed: strict

module M
  class Schema::Vocab
    sig { void }
    def initialize
      @_extra = T.let({}, T::Hash[Symbol, T::Boolean])
    end

    sig { params(key: Symbol).returns(T::Boolean) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: Symbol, value: T::Boolean).returns(T::Boolean) }
    def []=(key, value)
      @_extra[key] = value
    end
  end
end
