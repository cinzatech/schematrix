# typed: strict

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
    end

    sig { returns(T.nilable(String)) }
    def str
    end

    sig { params(str: T.nilable(String)).void }
    def str=(str)
    end

    sig { returns(T.nilable(Schema::Defs::Base)) }
    def refonly
    end

    sig { params(refonly: T.nilable(Schema::Defs::Base)).void }
    def refonly=(refonly)
    end

    sig { returns(T.nilable(Schema::Defs::Base)) }
    def both
    end

    sig { params(both: T.nilable(Schema::Defs::Base)).void }
    def both=(both)
    end

    sig { returns(T.nilable(Schema::Props::Typed)) }
    def typed
    end

    sig { params(typed: T.nilable(Schema::Props::Typed)).void }
    def typed=(typed)
    end

    sig { returns(T.nilable(Schema::Props::NullObject)) }
    def null_object
    end

    sig { params(null_object: T.nilable(Schema::Props::NullObject)).void }
    def null_object=(null_object)
    end

    sig { returns(T.nilable(T::Array[String])) }
    def str_arr
    end

    sig { params(str_arr: T.nilable(T::Array[String])).void }
    def str_arr=(str_arr)
    end

    sig { returns(T.nilable(String)) }
    def narrowed
    end

    sig { params(narrowed: T.nilable(String)).void }
    def narrowed=(narrowed)
    end

    sig { returns(T.nilable(T::Hash[String, Integer])) }
    def map_ref
    end

    sig { params(map_ref: T.nilable(T::Hash[String, Integer])).void }
    def map_ref=(map_ref)
    end

    sig { params(key: String).returns(T.anything) }
    def [](key)
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_refonly(value)
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_both(value)
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_typed(value)
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_null_object(value)
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
    end
  end
end
