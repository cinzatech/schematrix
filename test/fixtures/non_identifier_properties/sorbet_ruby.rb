# typed: strict

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS =
      T.let(
        { "first name" => :first_name, "a/b" => :a_b }.freeze,
        T::Hash[String, Symbol]
      )

    sig do
      params(
        first_name: T.nilable(Schema::Props::FirstName),
        a_b: T.nilable(Schema::Props::AB)
      ).void
    end
    def initialize(first_name: nil, a_b: nil)
      @first_name = first_name
      @a_b = a_b

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(Schema::Props::FirstName)) }
    attr_accessor :first_name

    sig { returns(T.nilable(Schema::Props::AB)) }
    attr_accessor :a_b

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(value: T.untyped, klass: T.untyped).returns(T.untyped) }
    def self.coerce_class_slot(value, klass)
      if value.is_a?(klass)
        value.to_h
      elsif value.is_a?(Hash)
        klass.from_h(value)
      else
        value
      end
    end

    sig { params(value: T.untyped, spec: T.untyped).returns(T.untyped) }
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

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_first_name(value)
      coerce_spec(value, [:class, M::Schema::Props::FirstName])
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_a_b(value)
      coerce_spec(value, [:class, M::Schema::Props::AB])
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
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

    sig { returns(T::Hash[String, T.untyped]) }
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
