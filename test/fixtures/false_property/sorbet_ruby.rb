# typed: strict

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS =
      T.let(
        { "name" => :name, "legacy" => :legacy }.freeze,
        T::Hash[String, Symbol]
      )

    sig { params(name: T.nilable(String), legacy: T.untyped).void }
    def initialize(name: nil, legacy: nil)
      @name = name
      @legacy = legacy

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :name

    sig { returns(T.untyped) }
    attr_accessor :legacy

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
      instance = new(name: hash["name"], legacy: hash["legacy"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      result = {}
      result["name"] = @name unless @name.nil?
      result["legacy"] = @legacy unless @legacy.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
