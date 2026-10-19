# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = {
      "flag" => :flag,
      "dead" => :dead,
      "sibling" => :sibling
    }.freeze

    sig do
      params(
        flag: T.anything,
        dead: T.nilable(T.noreturn),
        sibling: T.nilable(String)
      ).void
    end
    def initialize(flag: nil, dead: nil, sibling: nil)
      @flag = flag
      @dead = dead
      @sibling = sibling

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.anything) }
    attr_accessor :flag

    sig { returns(T.nilable(T.noreturn)) }
    attr_accessor :dead

    sig { returns(T.nilable(String)) }
    attr_accessor :sibling

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
      instance =
        new(flag: hash["flag"], dead: hash["dead"], sibling: hash["sibling"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
      result = {}
      result["flag"] = @flag unless @flag.nil?
      result["dead"] = @dead unless @dead.nil?
      result["sibling"] = @sibling unless @sibling.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
