module M
  class Schema
    ORIGINAL_KEYS = { "first name" => :first_name, "a/b" => :a_b }.freeze

    def initialize(first_name: nil, a_b: nil)
      @first_name = first_name
      @a_b = a_b

      @_extra = {}
    end

    attr_accessor :first_name, :a_b

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

    def self.coerce_first_name(value)
      coerce_class_slot(value, M::Schema::Props::FirstName)
    end

    def self.coerce_a_b(value)
      coerce_class_slot(value, M::Schema::Props::AB)
    end

    def self.from_h(hash)
      instance =
        new(
          first_name: coerce_first_name(hash["first name"]),
          a_b: coerce_a_b(hash["a/b"])
        )

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["first name"] = self.class.coerce_first_name(
        @first_name
      ) unless @first_name.nil?
      result["a/b"] = self.class.coerce_a_b(@a_b) unless @a_b.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
