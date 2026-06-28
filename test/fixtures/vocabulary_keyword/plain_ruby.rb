module M
  class WithVocab
    def initialize(name: nil)
      @name = name
    end

    attr_accessor :name
  end
end
