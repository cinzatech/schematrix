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

    def self.coerce_class_slot(value, klass)
      if value.is_a?(klass)
        value.to_h
      elsif value.is_a?(Hash)
        klass.from_h(value)
      else
        value
      end
    end

    def self.coerce_array_slot(value, klass)
      return value unless value.is_a?(Array)

      value.map { |element| coerce_class_slot(element, klass) }
    end

    def self.coerce_map_slot(value, klass)
      return value unless value.is_a?(Hash)

      value.transform_values { |entry| coerce_class_slot(entry, klass) }
    end

    def self.coerce_owner(value)
      coerce_class_slot(value, M::Schema::Defs::Named)
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
