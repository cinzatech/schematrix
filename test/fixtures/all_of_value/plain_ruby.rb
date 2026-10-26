module M
  class Schema
    ORIGINAL_KEYS = {
      "str" => :str,
      "refonly" => :refonly,
      "both" => :both,
      "typed" => :typed
    }.freeze

    def initialize(str: nil, refonly: nil, both: nil, typed: nil)
      @str = str
      @refonly = refonly
      @both = both
      @typed = typed

      @_extra = {}
    end

    attr_accessor :str, :refonly, :both, :typed

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

    def self.coerce_refonly(value)
      coerce_class_slot(value, M::Schema::Defs::Base)
    end

    def self.coerce_both(value)
      coerce_class_slot(value, M::Schema::Defs::Base)
    end

    def self.coerce_typed(value)
      coerce_class_slot(value, M::Schema::Props::Typed)
    end

    def self.from_h(hash)
      instance =
        new(
          str: hash["str"],
          refonly: coerce_refonly(hash["refonly"]),
          both: coerce_both(hash["both"]),
          typed: coerce_typed(hash["typed"])
        )

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["str"] = @str unless @str.nil?
      result["refonly"] = self.class.coerce_refonly(
        @refonly
      ) unless @refonly.nil?
      result["both"] = self.class.coerce_both(@both) unless @both.nil?
      result["typed"] = self.class.coerce_typed(@typed) unless @typed.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
