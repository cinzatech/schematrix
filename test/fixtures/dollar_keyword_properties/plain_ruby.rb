module M
  class Schema
    ORIGINAL_KEYS = {
      "$id" => :id,
      "if" => :if_,
      "then" => :then_,
      "$defs" => :defs,
      "named" => :named
    }.freeze

    def initialize(id: nil, if_: nil, then_: nil, defs: nil, named: nil)
      @id = id
      @if_ = if_
      @then_ = then_
      @defs = defs
      @named = named

      @_extra = {}
    end

    attr_accessor :id, :if_, :then_, :defs, :named

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

    def self.coerce_defs(value)
      coerce_class_slot(value, M::Schema::Props::Defs)
    end

    def self.coerce_named(value)
      coerce_class_slot(value, M::Schema::Defs::Named)
    end

    def self.from_h(hash)
      instance =
        new(
          id: hash["$id"],
          if_: hash["if"],
          then_: hash["then"],
          defs: coerce_defs(hash["$defs"]),
          named: coerce_named(hash["named"])
        )

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["$id"] = @id unless @id.nil?
      result["if"] = @if_ unless @if_.nil?
      result["then"] = @then_ unless @then_.nil?
      result["$defs"] = self.class.coerce_defs(@defs) unless @defs.nil?
      result["named"] = self.class.coerce_named(@named) unless @named.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
