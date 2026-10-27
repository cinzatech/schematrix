# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "home" => :home, "work" => :work }.freeze

    sig do
      params(
        home: T.nilable(Schema::Defs::Address),
        work: T.nilable(Schema::Defs::Address)
      ).void
    end
    def initialize(home: nil, work: nil)
    end

    sig { returns(T.nilable(Schema::Defs::Address)) }
    def home
    end

    sig { params(home: T.nilable(Schema::Defs::Address)).void }
    def home=(home)
    end

    sig { returns(T.nilable(Schema::Defs::Address)) }
    def work
    end

    sig { params(work: T.nilable(Schema::Defs::Address)).void }
    def work=(work)
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

    sig { params(value: T.anything, spec: T.anything).returns(T.anything) }
    def self.coerce_spec(value, spec)
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_home(value)
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_work(value)
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
    end
  end
end
