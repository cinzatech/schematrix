# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "point" => :point }.freeze

    sig { params(point: T.nilable(T::Array[Float])).void }
    def initialize(point: nil)
      @point = point

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(T::Array[Float])) }
    attr_accessor :point

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
      instance = new(point: hash["point"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
      result = {}
      result["point"] = @point unless @point.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
