# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "values" => :values }.freeze

    sig { params(values: T.nilable(T::Array[T.all(String, Integer)])).void }
    def initialize(values: nil)
      @values = values

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(T::Array[T.all(String, Integer)])) }
    attr_accessor :values

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
      instance = new(values: hash["values"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
      result = {}
      result["values"] = @values unless @values.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
