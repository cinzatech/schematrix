module M
  class Schema
    ORIGINAL_KEYS = { "name" => :name, "child" => :child }.freeze

    def initialize(name:, child: nil)
      @name = name
      @child = child

      @_extra = {}
    end

    attr_accessor :name, :child

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

    def self.coerce_child(value)
      coerce_class_slot(value, M::Schema::Props::Child)
    end

    def self.from_h(hash)
      instance = new(name: hash["name"], child: coerce_child(hash["child"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["name"] = @name unless @name.nil?
      result["child"] = self.class.coerce_child(@child) unless @child.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
