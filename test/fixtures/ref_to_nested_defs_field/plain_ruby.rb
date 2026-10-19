module M
  class Schema
    ORIGINAL_KEYS = { "items" => :items }.freeze

    def initialize(items: nil)
      @items = items

      @_extra = {}
    end

    attr_accessor :items

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.from_h(hash)
      instance = new(items: hash["items"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["items"] = @items unless @items.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
