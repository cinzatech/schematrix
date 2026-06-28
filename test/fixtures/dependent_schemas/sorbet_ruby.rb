# typed: strict

module M
  class DepSchemas
    sig { params(name: T.nilable(String), credit_card: T.nilable(String), billing_address: T.nilable(String)).void }
    def initialize(name: nil, credit_card: nil, billing_address: nil)
      @name = name
      @credit_card = credit_card
      @billing_address = billing_address
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :name

    sig { returns(T.nilable(String)) }
    attr_accessor :credit_card

    sig { returns(T.nilable(String)) }
    attr_accessor :billing_address
  end
end
