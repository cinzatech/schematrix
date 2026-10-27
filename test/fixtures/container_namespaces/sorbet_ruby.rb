# typed: strict

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS =
      T.let({ "home" => :home, "alt" => :alt }.freeze, T::Hash[String, Symbol])

    sig do
      params(
        home: T.nilable(Schema::Props::Home),
        alt: T.nilable(Schema::Defs::Address)
      ).void
    end
    def initialize(home: nil, alt: nil)
      @home = home
      @alt = alt

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(Schema::Props::Home)) }
    attr_accessor :home

    sig { returns(T.nilable(Schema::Defs::Address)) }
    attr_accessor :alt

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
    def self.coerce_home(value)
      coerce_spec(value, [:class, M::Schema::Props::Home])
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_alt(value)
      coerce_spec(value, [:class, M::Schema::Defs::Address])
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
    def self.from_h(hash)
      instance =
        new(home: coerce_home(hash["home"]), alt: coerce_alt(hash["alt"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      result = {}
      result["home"] = self.class.coerce_home(@home) unless @home.nil?
      result["alt"] = self.class.coerce_alt(@alt) unless @alt.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
