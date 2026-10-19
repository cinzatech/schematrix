# typed: strict

module M
  class Schema
    sig { params(vocab: T.nilable(T::Hash[String, T::Boolean])).void }
    def initialize(vocab: nil)
    end

    sig { returns(T.nilable(T::Hash[String, T::Boolean])) }
    def vocab
    end

    sig { params(vocab: T.nilable(T::Hash[String, T::Boolean])).void }
    def vocab=(vocab)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
