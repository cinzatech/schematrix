# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "score" => :score }.freeze

    sig { params(score: T.nilable(Numeric)).void }
    def initialize(score: nil)
      @score = score

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(Numeric)) }
    attr_accessor :score

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
      instance = new(score: hash["score"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
      result = {}
      result["score"] = @score unless @score.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
