# typed: strict

module M
  class Schema
    sig { params(items: T.anything).void }
    def initialize(items: nil)
      @items = items
    end

    sig { returns(T.anything) }
    attr_accessor :items
  end
end
