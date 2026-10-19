module M
  class Schema
    ORIGINAL_KEYS = {
      "name" => :name,
      "credit_card" => :credit_card,
      "billing_address" => :billing_address
    }.freeze

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
