module M
  class Schema
    ORIGINAL_KEYS = { "value" => :value, "children" => :children }.freeze

    def initialize(value: nil, children: nil)
      @value = value
      @children = children

      @_extra = {}
    end

    attr_accessor :value, :children

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

    def self.coerce_children(value)
      coerce_array_slot(value, M::Schema)
    end

    def self.from_h(hash)
      instance =
        new(value: hash["value"], children: coerce_children(hash["children"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["value"] = @value unless @value.nil?
      result["children"] = self.class.coerce_children(
        @children
      ) unless @children.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
