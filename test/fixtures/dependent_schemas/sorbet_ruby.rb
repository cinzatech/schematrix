# typed: strict

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS =
      T.let(
        {
          "name" => :name,
          "credit_card" => :credit_card,
          "billing_address" => :billing_address
        }.freeze,
        T::Hash[String, Symbol]
      )

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

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :name

    sig { returns(T.nilable(String)) }
    attr_accessor :credit_card

    sig { returns(T.nilable(String)) }
    attr_accessor :billing_address

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
    def self.from_h(hash)
      instance =
        new(
          name: hash["name"],
          credit_card: hash["credit_card"],
          billing_address: hash["billing_address"]
        )

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      result = {}
      result["name"] = @name unless @name.nil?
      result["credit_card"] = @credit_card unless @credit_card.nil?
      result["billing_address"] = @billing_address unless @billing_address.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
