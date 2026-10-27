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

    def self.coerce_defs(value)
      coerce_spec(value, [:class, M::Schema::Props::Defs])
    end

    def self.coerce_named(value)
      coerce_spec(value, [:class, M::Schema::Defs::Named])
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
