# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "name" => :name, "legacy" => :legacy }.freeze

    sig { params(name: T.nilable(String), legacy: T.nilable(T.noreturn)).void }
    def initialize(name: nil, legacy: nil)
      @name = name
      @legacy = legacy

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :name

    sig { returns(T.nilable(T.noreturn)) }
    attr_accessor :legacy

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
      instance = new(name: hash["name"], legacy: hash["legacy"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
      result = {}
      result["name"] = @name unless @name.nil?
      result["legacy"] = @legacy unless @legacy.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
