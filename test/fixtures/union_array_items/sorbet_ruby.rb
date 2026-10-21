# typed: strict

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS = T.let({ "tags" => :tags }.freeze, T::Hash[String, Symbol])

    sig { params(tags: T.nilable(T::Array[T.any(String, Integer)])).void }
    def initialize(tags: nil)
      @tags = tags

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(T::Array[T.any(String, Integer)])) }
    attr_accessor :tags

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
    def self.from_h(hash)
      instance = new(tags: hash["tags"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      result = {}
      result["tags"] = @tags unless @tags.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
