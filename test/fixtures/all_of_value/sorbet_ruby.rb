# typed: strict

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS =
      T.let(
        {
          "str" => :str,
          "refonly" => :refonly,
          "both" => :both,
          "typed" => :typed
        }.freeze,
        T::Hash[String, Symbol]
      )

    sig do
      params(
        str: T.nilable(String),
        refonly: T.nilable(Schema::Defs::Base),
        both: T.nilable(Schema::Defs::Base),
        typed: T.nilable(Schema::Props::Typed)
      ).void
    end
    def initialize(str: nil, refonly: nil, both: nil, typed: nil)
      @str = str
      @refonly = refonly
      @both = both
      @typed = typed

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :str

    sig { returns(T.nilable(Schema::Defs::Base)) }
    attr_accessor :refonly

    sig { returns(T.nilable(Schema::Defs::Base)) }
    attr_accessor :both

    sig { returns(T.nilable(Schema::Props::Typed)) }
    attr_accessor :typed

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

    sig { params(value: T.untyped, klass: T.untyped).returns(T.untyped) }
    def self.coerce_array_slot(value, klass)
      return value unless value.is_a?(Array)

      value.map { |element| coerce_class_slot(element, klass) }
    end

    sig { params(value: T.untyped, klass: T.untyped).returns(T.untyped) }
    def self.coerce_map_slot(value, klass)
      return value unless value.is_a?(Hash)

      value.transform_values { |entry| coerce_class_slot(entry, klass) }
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_refonly(value)
      coerce_class_slot(value, M::Schema::Defs::Base)
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_both(value)
      coerce_class_slot(value, M::Schema::Defs::Base)
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_typed(value)
      coerce_class_slot(value, M::Schema::Props::Typed)
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
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

    sig { returns(T::Hash[String, T.untyped]) }
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
