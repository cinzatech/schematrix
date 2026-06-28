module M
  class DepSchemas
    def initialize(name: nil, credit_card: nil, billing_address: nil)
      @name = name
      @credit_card = credit_card
      @billing_address = billing_address
    end

    attr_accessor :name, :credit_card, :billing_address
  end
end
