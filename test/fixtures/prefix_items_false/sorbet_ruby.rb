# typed: strict

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS = T.let({ "flags" => :flags }.freeze, T::Hash[String, Symbol])

    sig { params(flags: T.nilable(T::Array[String])).void }
    def initialize(flags: nil)
      @flags = flags

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(T::Array[String])) }
    attr_accessor :flags

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
      instance = new(flags: hash["flags"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      result = {}
      result["flags"] = @flags unless @flags.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
