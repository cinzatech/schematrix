module M
  class PropNames
    def initialize(vocab: nil)
      @vocab = vocab
    end

    attr_accessor :vocab
  end
end
