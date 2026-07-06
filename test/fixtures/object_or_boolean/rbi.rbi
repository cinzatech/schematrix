# typed: strict

module M
  class Schema
    sig { params(meta: T.nilable(T.any(Schema::Meta, T::Boolean))).void }
    def initialize(meta: nil)
    end

    sig { returns(T.nilable(T.any(Schema::Meta, T::Boolean))) }
    def meta
    end

    sig { params(meta: T.nilable(T.any(Schema::Meta, T::Boolean))).void }
    def meta=(meta)
    end
  end
end
