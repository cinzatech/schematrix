module M
  class Schema
    ORIGINAL_KEYS = { "address" => :address }.freeze

    def initialize(address: nil)
      @address = address

      @_extra = {}
    end

    attr_accessor :address

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.coerce_address(value)
      if value.is_a?(M::Schema::Props::Address)
        value.to_h
      elsif value.is_a?(Hash)
        M::Schema::Props::Address.from_h(value)
      else
        value
      end
    end

    def self.from_h(hash)
      instance = new(address: coerce_address(hash["address"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["address"] = self.class.coerce_address(
        @address
      ) unless @address.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
