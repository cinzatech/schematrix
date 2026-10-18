module M
  class Schema
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
  end
end
