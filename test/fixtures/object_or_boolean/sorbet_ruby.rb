# typed: strict

module M
  class Schema
    sig { params(meta: T.nilable(T.any(Schema::Props::Meta, T::Boolean))).void }
    def initialize(meta: nil)
      @meta = meta

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.nilable(T.any(Schema::Props::Meta, T::Boolean))) }
    attr_accessor :meta

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end
  end
end
