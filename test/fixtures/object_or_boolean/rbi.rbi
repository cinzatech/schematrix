# typed: strict

module M
  class Schema
    sig { params(meta: T.nilable(T.any(Schema::Props::Meta, T::Boolean))).void }
    def initialize(meta: nil)
    end

    sig { returns(T.nilable(T.any(Schema::Props::Meta, T::Boolean))) }
    def meta
    end

    sig { params(meta: T.nilable(T.any(Schema::Props::Meta, T::Boolean))).void }
    def meta=(meta)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
