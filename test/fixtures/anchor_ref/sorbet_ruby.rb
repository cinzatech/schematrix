# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "owner" => :owner }.freeze

    sig { params(owner: T.nilable(Schema::Defs::Named)).void }
    def initialize(owner: nil)
      @owner = owner

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(Schema::Defs::Named)) }
    attr_accessor :owner

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_owner(value)
      if value.is_a?(M::Schema::Defs::Named)
        value.to_h
      elsif value.is_a?(Hash)
        M::Schema::Defs::Named.from_h(value)
      else
        value
      end
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
      instance = new(owner: coerce_owner(hash["owner"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
      result = {}
      result["owner"] = self.class.coerce_owner(@owner) unless @owner.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
