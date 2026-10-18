# typed: strict

module M
  class Schema
    sig do
      params(
        name: T.nilable(String),
        credit_card: T.nilable(String),
        billing_address: T.nilable(String)
      ).void
    end
    def initialize(name: nil, credit_card: nil, billing_address: nil)
      @name = name
      @credit_card = credit_card
      @billing_address = billing_address

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :name

    sig { returns(T.nilable(String)) }
    attr_accessor :credit_card

    sig { returns(T.nilable(String)) }
    attr_accessor :billing_address

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end
  end
end
