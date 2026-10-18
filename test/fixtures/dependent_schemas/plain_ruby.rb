module M
  class Schema
    def initialize(name: nil, credit_card: nil, billing_address: nil)
      @name = name
      @credit_card = credit_card
      @billing_address = billing_address

      @_extra = {}
    end

    attr_accessor :name, :credit_card, :billing_address

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
