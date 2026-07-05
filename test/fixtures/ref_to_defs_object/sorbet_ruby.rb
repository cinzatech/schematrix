# typed: strict

module M
  class Schema
    sig { params(address: T.anything).void }
    def initialize(address: nil)
      @address = address
    end

    sig { returns(T.anything) }
    attr_accessor :address
  end
end
