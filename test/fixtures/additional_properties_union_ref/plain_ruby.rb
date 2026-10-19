module M
  class Schema
    ORIGINAL_KEYS = { "always" => :always }.freeze

    def initialize(always: nil)
      @always = always

      @_extra = {}
    end

    attr_accessor :always

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.from_h(hash)
      instance = new(always: hash["always"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["always"] = @always unless @always.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
