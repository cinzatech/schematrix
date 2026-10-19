module M
  class Schema
    ORIGINAL_KEYS = { "value" => :value }.freeze

    def initialize(value: nil)
      @value = value

      @_extra = {}
    end

    attr_accessor :value

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.coerce_value(value)
      if value.is_a?(M::Schema::Defs::Named)
        value.to_h
      elsif value.is_a?(Hash)
        M::Schema::Defs::Named.from_h(value)
      else
        value
      end
    end

    def self.from_h(hash)
      instance = new(value: coerce_value(hash["value"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["value"] = self.class.coerce_value(@value) unless @value.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
