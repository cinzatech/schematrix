# typed: strict

module M
  class Schema
    sig { params(vocab: T.nilable(Schema::Props::Vocab)).void }
    def initialize(vocab: nil)
    end

    sig { returns(T.nilable(Schema::Props::Vocab)) }
    def vocab
    end

    sig { params(vocab: T.nilable(Schema::Props::Vocab)).void }
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
