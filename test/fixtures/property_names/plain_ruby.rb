module M
  class Schema
    ORIGINAL_KEYS = { "vocab" => :vocab }.freeze

    def initialize(vocab: nil)
      @vocab = vocab

      @_extra = {}
    end

    attr_accessor :vocab

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.from_h(hash)
      instance = new(vocab: hash["vocab"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["vocab"] = @vocab unless @vocab.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
