# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "scores" => :scores }.freeze

    sig { params(scores: T.nilable(T::Array[Integer])).void }
    def initialize(scores: nil)
      @scores = scores

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(T::Array[Integer])) }
    attr_accessor :scores

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
      instance = new(scores: hash["scores"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
      result = {}
      result["scores"] = @scores unless @scores.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
