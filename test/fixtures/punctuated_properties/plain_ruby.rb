module M
  class Schema
    ORIGINAL_KEYS = {
      "example.com" => :example_com,
      "web.hook" => :web_hook
    }.freeze

    def initialize(example_com: nil, web_hook: nil)
      @example_com = example_com
      @web_hook = web_hook

      @_extra = {}
    end

    attr_accessor :example_com, :web_hook

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

    def self.coerce_web_hook(value)
      coerce_spec(value, [:class, M::Schema::Props::WebHook])
    end

    def self.from_h(hash)
      instance =
        new(
          example_com: hash["example.com"],
          web_hook: coerce_web_hook(hash["web.hook"])
        )

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["example.com"] = @example_com unless @example_com.nil?
      result["web.hook"] = self.class.coerce_web_hook(
        @web_hook
      ) unless @web_hook.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
