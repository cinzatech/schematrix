module M
  class Schema
    ORIGINAL_KEYS = { "flags" => :flags }.freeze

    def initialize(flags: nil)
      @flags = flags

      @_extra = {}
    end

    attr_accessor :flags

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.from_h(hash)
      instance = new(flags: hash["flags"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["flags"] = @flags unless @flags.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
