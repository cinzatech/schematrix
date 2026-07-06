# typed: strict

module M
  class Schema
    sig { params(meta: T.nilable(T.any(Schema::Meta, T::Boolean))).void }
    def initialize(meta: nil)
      @meta = meta
    end

    sig { returns(T.nilable(T.any(Schema::Meta, T::Boolean))) }
    attr_accessor :meta
  end
end
