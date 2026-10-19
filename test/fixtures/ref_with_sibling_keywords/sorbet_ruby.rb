# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "anchor" => :anchor }.freeze

    sig { params(anchor: T.nilable(String)).void }
    def initialize(anchor: "myAnchor")
      @anchor = anchor

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :anchor

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
      instance = new
      instance.anchor = hash["anchor"] if hash.key?("anchor")

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
      result = {}
      result["anchor"] = @anchor unless @anchor.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
