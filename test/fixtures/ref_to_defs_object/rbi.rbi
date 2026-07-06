# typed: strict

module M
  class Schema
    sig { params(address: T.nilable(Schema::Address)).void }
    def initialize(address: nil)
    end

    sig { returns(T.nilable(Schema::Address)) }
    def address
    end

    sig { params(address: T.nilable(Schema::Address)).void }
    def address=(address)
    end
  end
end
