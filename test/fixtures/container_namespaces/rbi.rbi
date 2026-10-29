# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "home" => :home, "alt" => :alt }.freeze

    sig do
      params(
        home: T.nilable(Schema::Props::Home),
        alt: T.nilable(Schema::Defs::Address)
      ).void
    end
    def initialize(home: nil, alt: nil)
    end

    sig { returns(T.nilable(Schema::Props::Home)) }
    def home
    end

    sig { params(home: T.nilable(Schema::Props::Home)).void }
    def home=(home)
    end

    sig { returns(T.nilable(Schema::Defs::Address)) }
    def alt
    end

    sig { params(alt: T.nilable(Schema::Defs::Address)).void }
    def alt=(alt)
    end

    sig { params(key: String).returns(T.anything) }
    def [](key)
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_home(value)
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_alt(value)
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
    end
  end
end
