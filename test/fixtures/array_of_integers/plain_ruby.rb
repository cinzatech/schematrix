module M
  class Schema
    ORIGINAL_KEYS = { "scores" => :scores }.freeze

    def initialize(scores: nil)
      @scores = scores

      @_extra = {}
    end

    attr_accessor :scores

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.from_h(hash)
      instance = new(scores: hash["scores"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["scores"] = @scores unless @scores.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
