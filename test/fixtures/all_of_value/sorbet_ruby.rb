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
          "typed" => :typed,
          "null_object" => :null_object,
          "str_arr" => :str_arr,
          "narrowed" => :narrowed,
          "map_ref" => :map_ref
        }.freeze,
        T::Hash[String, Symbol]
      )

    sig do
      params(
        str: T.nilable(String),
        refonly: T.nilable(Schema::Defs::Base),
        both: T.nilable(Schema::Defs::Base),
        typed: T.nilable(Schema::Props::Typed),
        null_object: T.nilable(Schema::Props::NullObject),
        str_arr: T.nilable(T::Array[String]),
        narrowed: T.nilable(String),
        map_ref: T.nilable(T::Hash[String, Integer])
      ).void
    end
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

    sig { returns(T.nilable(Schema::Props::NullObject)) }
    attr_accessor :null_object

    sig { returns(T.nilable(T::Array[String])) }
    attr_accessor :str_arr

    sig { returns(T.nilable(String)) }
    attr_accessor :narrowed

    sig { returns(T.nilable(T::Hash[String, Integer])) }
    attr_accessor :map_ref

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

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_null_object(value)
      coerce_class_slot(value, M::Schema::Props::NullObject)
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
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

    sig { returns(T::Hash[String, T.untyped]) }
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
