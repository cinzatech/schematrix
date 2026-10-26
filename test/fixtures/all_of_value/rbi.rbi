# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = {
      "str" => :str,
      "refonly" => :refonly,
      "both" => :both,
      "typed" => :typed
    }.freeze

    sig do
      params(
        str: T.nilable(String),
        refonly: T.nilable(Schema::Defs::Base),
        both: T.nilable(Schema::Defs::Base),
        typed: T.nilable(Schema::Props::Typed)
      ).void
    end
    def initialize(str: nil, refonly: nil, both: nil, typed: nil)
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

    sig { params(key: String).returns(T.anything) }
    def [](key)
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end

    sig { params(value: T.anything, klass: T.anything).returns(T.anything) }
    def self.coerce_class_slot(value, klass)
    end

    sig { params(value: T.anything, klass: T.anything).returns(T.anything) }
    def self.coerce_array_slot(value, klass)
    end

    sig { params(value: T.anything, klass: T.anything).returns(T.anything) }
    def self.coerce_map_slot(value, klass)
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

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
    end
  end
end
