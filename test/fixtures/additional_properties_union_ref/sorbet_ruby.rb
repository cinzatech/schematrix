# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "always" => :always }.freeze

    sig { params(always: T.nilable(T::Boolean)).void }
    def initialize(always: nil)
      @always = always

      @_extra =
        T.let(
          {},
          T::Hash[String, T.nilable(T.any(String, Schema::Defs::Thing))]
        )
    end

    sig { returns(T.nilable(T::Boolean)) }
    attr_accessor :always

    sig do
      params(key: String).returns(T.nilable(T.any(String, Schema::Defs::Thing)))
    end
    def [](key)
      @_extra[key]
    end

    sig do
      params(
        key: String,
        value: T.nilable(T.any(String, Schema::Defs::Thing))
      ).returns(T.nilable(T.any(String, Schema::Defs::Thing)))
    end
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
      instance = new(always: hash["always"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
      result = {}
      result["always"] = @always unless @always.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
