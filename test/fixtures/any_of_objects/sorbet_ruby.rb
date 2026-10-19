# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "value" => :value }.freeze

    sig { params(value: T.nilable(T.any(Schema::Props::Value, String))).void }
    def initialize(value: nil)
      @value = value

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(T.any(Schema::Props::Value, String))) }
    attr_accessor :value

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_value(value)
      if value.is_a?(M::Schema::Props::Value)
        value.to_h
      elsif value.is_a?(Hash)
        M::Schema::Props::Value.from_h(value)
      else
        value
      end
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
      instance = new(value: coerce_value(hash["value"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
      result = {}
      result["value"] = self.class.coerce_value(@value) unless @value.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
