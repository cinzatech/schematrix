# typed: strict

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS = T.let({ "a" => :a }.freeze, T::Hash[String, Symbol])

    sig { params(a: T.untyped).void }
    def initialize(a: nil)
      @a = a

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.untyped) }
    attr_accessor :a

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
      instance = new(a: hash["a"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      result = {}
      result["a"] = @a unless @a.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
