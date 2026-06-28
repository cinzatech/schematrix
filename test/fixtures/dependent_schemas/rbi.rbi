# typed: strict

module M
  class DepSchemas
    sig { params(name: T.nilable(String), credit_card: T.nilable(String), billing_address: T.nilable(String)).void }
    def initialize(name: nil, credit_card: nil, billing_address: nil)
    end

    sig { returns(T.nilable(String)) }
    def name
    end

    sig { params(name: T.nilable(String)).void }
    def name=(name)
    end

    sig { returns(T.nilable(String)) }
    def credit_card
    end

    sig { params(credit_card: T.nilable(String)).void }
    def credit_card=(credit_card)
    end

    sig { returns(T.nilable(String)) }
    def billing_address
    end

    sig { params(billing_address: T.nilable(String)).void }
    def billing_address=(billing_address)
    end
  end
end
