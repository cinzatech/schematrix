# typed: strict

module M
  class Schema
    sig { params(vocab: T.nilable(Schema::Vocab)).void }
    def initialize(vocab: nil)
      @vocab = vocab
    end

    sig { returns(T.nilable(Schema::Vocab)) }
    attr_accessor :vocab
  end
end
