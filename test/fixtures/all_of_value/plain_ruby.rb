module M
  class Schema
    ORIGINAL_KEYS = {
      "str" => :str,
      "refonly" => :refonly,
      "both" => :both,
      "typed" => :typed,
      "null_object" => :null_object,
      "str_arr" => :str_arr,
      "narrowed" => :narrowed,
      "map_ref" => :map_ref
    }.freeze

    def initialize(
      str: nil,
      refonly: nil,
      both: nil,
      typed: nil,
      null_object: nil,
      str_arr: nil,
      narrowed: nil,
      map_ref: nil
    )
      @str = str
      @refonly = refonly
      @both = both
      @typed = typed
      @null_object = null_object
      @str_arr = str_arr
      @narrowed = narrowed
      @map_ref = map_ref

      @_extra = {}
    end

    attr_accessor :str,
                  :refonly,
                  :both,
                  :typed,
                  :null_object,
                  :str_arr,
                  :narrowed,
                  :map_ref

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

    def self.coerce_spec(value, spec)
      case spec[0]
      when :coerce
        spec[1].coerce(value)
      when :class
        coerce_class_slot(value, spec[1])
      when :array
        return value unless value.is_a?(Array)

        if spec[1][0] == :tuple
          prefix, tail = spec[1][1], spec[1][2]
          value.each_with_index.map do |element, index|
            sub = index < prefix.size ? prefix[index] : tail
            sub.nil? ? element : coerce_spec(element, sub)
          end
        else
          value.map { |element| coerce_spec(element, spec[1]) }
        end
      when :map
        return value unless value.is_a?(Hash)

        value.transform_values { |entry| coerce_spec(entry, spec[1]) }
      when :union
        result = value
        spec[1].each do |sub|
          case sub[0]
          when :class
            result = coerce_class_slot(result, sub[1])
          when :array
            if result.is_a?(Array)
              result = result.map { |element| coerce_spec(element, sub[1]) }
            end
          when :map
            if result.is_a?(Hash)
              result =
                result.transform_values { |entry| coerce_spec(entry, sub[1]) }
            end
          when :coerce
            result = sub[1].coerce(result)
          end
        end
        result
      end
    end

    def self.coerce_refonly(value)
      coerce_spec(value, [:class, M::Schema::Defs::Base])
    end

    def self.coerce_both(value)
      coerce_spec(value, [:class, M::Schema::Defs::Base])
    end

    def self.coerce_typed(value)
      coerce_spec(value, [:class, M::Schema::Props::Typed])
    end

    def self.coerce_null_object(value)
      coerce_spec(value, [:class, M::Schema::Props::NullObject])
    end

    def self.from_h(hash)
      instance =
        new(
          str: hash["str"],
          refonly: coerce_refonly(hash["refonly"]),
          both: coerce_both(hash["both"]),
          typed: coerce_typed(hash["typed"]),
          null_object: coerce_null_object(hash["null_object"]),
          str_arr: hash["str_arr"],
          narrowed: hash["narrowed"],
          map_ref: hash["map_ref"]
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
      result["null_object"] = self.class.coerce_null_object(
        @null_object
      ) unless @null_object.nil?
      result["str_arr"] = @str_arr unless @str_arr.nil?
      result["narrowed"] = @narrowed unless @narrowed.nil?
      result["map_ref"] = @map_ref unless @map_ref.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
