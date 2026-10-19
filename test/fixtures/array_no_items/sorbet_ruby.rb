# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "data" => :data }.freeze

    sig { params(data: T.nilable(T::Array[T.anything])).void }
    def initialize(data: nil)
      @data = data

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(T::Array[T.anything])) }
    attr_accessor :data

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
      instance = new(data: hash["data"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
      result = {}
      result["data"] = @data unless @data.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
