# typed: strict

module M
  class Schema
    sig { params(vocab: T.nilable(Schema::Vocab)).void }
    def initialize(vocab: nil)
    end

    sig { returns(T.nilable(Schema::Vocab)) }
    def vocab
    end

    sig { params(vocab: T.nilable(Schema::Vocab)).void }
    def vocab=(vocab)
    end
  end
end
