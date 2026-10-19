# typed: strict

module M
  class Schema
    sig { params(always: T.nilable(T::Boolean)).void }
    def initialize(always: nil)
      @always = always

      @_extra =
        T.let(
          {},
          T::Hash[Symbol, T.nilable(T.any(String, Schema::Defs::Thing))]
        )
    end

    sig { returns(T.nilable(T::Boolean)) }
    attr_accessor :always

    sig do
      params(key: Symbol).returns(T.nilable(T.any(String, Schema::Defs::Thing)))
    end
    def [](key)
      @_extra[key]
    end

    sig do
      params(
        key: Symbol,
        value: T.nilable(T.any(String, Schema::Defs::Thing))
      ).returns(T.nilable(T.any(String, Schema::Defs::Thing)))
    end
    def []=(key, value)
      @_extra[key] = value
    end
  end
end
