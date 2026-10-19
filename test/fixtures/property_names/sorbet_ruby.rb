# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "vocab" => :vocab }.freeze

    sig { params(vocab: T.nilable(T::Hash[String, T::Boolean])).void }
    def initialize(vocab: nil)
      @vocab = vocab

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(T::Hash[String, T::Boolean])) }
    attr_accessor :vocab

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
      instance = new(vocab: hash["vocab"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
      result = {}
      result["vocab"] = @vocab unless @vocab.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
