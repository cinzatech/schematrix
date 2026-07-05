module M
  class Schema
    def initialize(vocab: nil)
      @vocab = vocab
    end

    attr_accessor :vocab
  end
end
