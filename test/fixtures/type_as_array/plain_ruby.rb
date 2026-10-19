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

    def self.from_h(hash)
      instance = new(value: hash["value"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["value"] = @value unless @value.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
