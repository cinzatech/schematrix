module M
  class Schema
    ORIGINAL_KEYS = {
      "shipping_address" => :shipping_address,
      "billing_address" => :billing_address,
      "contact" => :contact,
      "email" => :email
    }.freeze

    def initialize(
      shipping_address: nil,
      billing_address: nil,
      contact: nil,
      email: nil
    )
      @shipping_address = shipping_address
      @billing_address = billing_address
      @contact = contact
      @email = email

      @_extra = {}
    end

    attr_accessor :shipping_address, :billing_address, :contact, :email

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.coerce_shipping_address(value)
      if value.is_a?(M::Address)
        value.to_h
      elsif value.is_a?(Hash)
        M::Address.from_h(value)
      else
        value
      end
    end

    def self.coerce_billing_address(value)
      if value.is_a?(M::PostalAddress)
        value.to_h
      elsif value.is_a?(Hash)
        M::PostalAddress.from_h(value)
      else
        value
      end
    end

    def self.coerce_contact(value)
      if value.is_a?(M::Address::Props::Zip)
        value.to_h
      elsif value.is_a?(Hash)
        M::Address::Props::Zip.from_h(value)
      else
        value
      end
    end

    def self.from_h(hash)
      instance =
        new(
          shipping_address: coerce_shipping_address(hash["shipping_address"]),
          billing_address: coerce_billing_address(hash["billing_address"]),
          contact: coerce_contact(hash["contact"]),
          email: hash["email"]
        )

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["shipping_address"] = self.class.coerce_shipping_address(
        @shipping_address
      ) unless @shipping_address.nil?
      result["billing_address"] = self.class.coerce_billing_address(
        @billing_address
      ) unless @billing_address.nil?
      result["contact"] = self.class.coerce_contact(
        @contact
      ) unless @contact.nil?
      result["email"] = @email unless @email.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
