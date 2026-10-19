module M
  class Schema
    ORIGINAL_KEYS = { "owner" => :owner }.freeze

    def initialize(owner: nil)
      @owner = owner

      @_extra = {}
    end

    attr_accessor :owner

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.coerce_owner(value)
      if value.is_a?(M::Schema::Defs::Named)
        value.to_h
      elsif value.is_a?(Hash)
        M::Schema::Defs::Named.from_h(value)
      else
        value
      end
    end

    def self.from_h(hash)
      instance = new(owner: coerce_owner(hash["owner"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["owner"] = self.class.coerce_owner(@owner) unless @owner.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
