# typed: strict

module M
  class Schema
    sig { params(address: T.nilable(Schema::Address)).void }
    def initialize(address: nil)
      @address = address
    end

    sig { returns(T.nilable(Schema::Address)) }
    attr_accessor :address
  end
end
