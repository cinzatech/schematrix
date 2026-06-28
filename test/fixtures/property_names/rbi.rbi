# typed: strict

module M
  class PropNames
    sig { params(vocab: T.nilable(T::Hash[String, T::Boolean])).void }
    def initialize(vocab: nil)
    end

    sig { returns(T.nilable(T::Hash[String, T::Boolean])) }
    def vocab
    end

    sig { params(vocab: T.nilable(T::Hash[String, T::Boolean])).void }
    def vocab=(vocab)
    end
  end
end
