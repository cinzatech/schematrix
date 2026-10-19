module M
  class Schema
    ORIGINAL_KEYS = { "config" => :config }.freeze

    def initialize(config: nil)
      @config = config

      @_extra = {}
    end

    attr_accessor :config

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.from_h(hash)
      instance = new(config: hash["config"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["config"] = @config unless @config.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
