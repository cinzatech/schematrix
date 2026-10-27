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

    def self.coerce_class_slot(value, klass)
      if value.is_a?(klass)
        value.to_h
      elsif value.is_a?(Hash)
        klass.from_h(value)
      else
        value
      end
    end

    def self.coerce_spec(value, spec)
      case spec[0]
      when :coerce
        spec[1].coerce(value)
      when :class
        coerce_class_slot(value, spec[1])
      when :array
        return value unless value.is_a?(Array)

        if spec[1][0] == :tuple
          prefix, tail = spec[1][1], spec[1][2]
          value.each_with_index.map do |element, index|
            sub = index < prefix.size ? prefix[index] : tail
            sub.nil? ? element : coerce_spec(element, sub)
          end
        else
          value.map { |element| coerce_spec(element, spec[1]) }
        end
      when :map
        return value unless value.is_a?(Hash)

        value.transform_values { |entry| coerce_spec(entry, spec[1]) }
      when :union
        result = value
        spec[1].each do |sub|
          case sub[0]
          when :class
            result = coerce_class_slot(result, sub[1])
          when :array
            if result.is_a?(Array)
              result = result.map { |element| coerce_spec(element, sub[1]) }
            end
          when :map
            if result.is_a?(Hash)
              result =
                result.transform_values { |entry| coerce_spec(entry, sub[1]) }
            end
          when :coerce
            result = sub[1].coerce(result)
          end
        end
        result
      end
    end

    def self.coerce_shipping_address(value)
      coerce_spec(value, [:class, M::Address])
    end

    def self.coerce_billing_address(value)
      coerce_spec(value, [:class, M::PostalAddress])
    end

    def self.coerce_contact(value)
      coerce_spec(value, [:class, M::Address::Props::Zip])
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
