module M
  class Schema
    ORIGINAL_KEYS = { "name" => :name, "legacy" => :legacy }.freeze

    def initialize(name: nil, legacy: nil)
      @name = name
      @legacy = legacy

      @_extra = {}
    end

    attr_accessor :name, :legacy

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.from_h(hash)
      instance = new(name: hash["name"], legacy: hash["legacy"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["name"] = @name unless @name.nil?
      result["legacy"] = @legacy unless @legacy.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
