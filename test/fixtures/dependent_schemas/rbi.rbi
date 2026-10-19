# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = {
      "name" => :name,
      "credit_card" => :credit_card,
      "billing_address" => :billing_address
    }.freeze

    sig do
      params(
        name: T.nilable(String),
        credit_card: T.nilable(String),
        billing_address: T.nilable(String)
      ).void
    end
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

    sig { params(key: String).returns(T.anything) }
    def [](key)
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
    end
  end
end
