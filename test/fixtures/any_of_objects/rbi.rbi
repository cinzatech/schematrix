# typed: strict

module M
  class Schema
    sig { params(value: T.nilable(T.any(Schema::Value, String))).void }
    def initialize(value: nil)
    end

    sig { returns(T.nilable(T.any(Schema::Value, String))) }
    def value
    end

    sig { params(value: T.nilable(T.any(Schema::Value, String))).void }
    def value=(value)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
