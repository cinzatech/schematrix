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
  end
end
