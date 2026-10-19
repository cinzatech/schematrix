module M
  class Schema
    ORIGINAL_KEYS = { "a" => :a }.freeze

    def initialize(a: nil)
      @a = a

      @_extra = {}
    end

    attr_accessor :a

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.from_h(hash)
      instance = new(a: hash["a"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["a"] = @a unless @a.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
