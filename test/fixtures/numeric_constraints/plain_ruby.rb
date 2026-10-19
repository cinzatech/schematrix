module M
  class Schema
    ORIGINAL_KEYS = { "score" => :score }.freeze

    def initialize(score: nil)
      @score = score

      @_extra = {}
    end

    attr_accessor :score

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.from_h(hash)
      instance = new(score: hash["score"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["score"] = @score unless @score.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
