module M
  class Schema
    ORIGINAL_KEYS = { "values" => :values }.freeze

    def initialize(values: nil)
      @values = values

      @_extra = {}
    end

    attr_accessor :values

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.from_h(hash)
      instance = new(values: hash["values"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["values"] = @values unless @values.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
