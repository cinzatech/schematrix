# typed: strict

module M
  class PropNames
    sig { params(vocab: T.nilable(T::Hash[String, T::Boolean])).void }
    def initialize(vocab: nil)
      @vocab = vocab
    end

    sig { returns(T.nilable(T::Hash[String, T::Boolean])) }
    attr_accessor :vocab
  end
end
