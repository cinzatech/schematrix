require_relative "coercion_helper"

module M
  class Address
    ORIGINAL_KEYS = { "street" => :street, "zip" => :zip }.freeze

    def initialize(street: nil, zip: nil)
      @street = street
      @zip = zip

      @_extra = {}
    end

    attr_accessor :street, :zip

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.coerce_zip(value)
      ::M::CoercionHelper.coerce_spec(value, [:class, M::Address::Props::Zip])
    end

    def self.from_h(hash)
      instance = new(street: hash["street"], zip: coerce_zip(hash["zip"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["street"] = @street unless @street.nil?
      result["zip"] = self.class.coerce_zip(@zip) unless @zip.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
