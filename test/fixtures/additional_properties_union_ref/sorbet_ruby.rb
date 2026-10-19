# typed: strict

module M
  class Schema
    sig { params(always: T.nilable(T::Boolean)).void }
    def initialize(always: nil)
      @always = always

      @_extra =
        T.let({}, T::Hash[Symbol, T.nilable(T.any(String, Schema::Thing))])
    end

    sig { returns(T.nilable(T::Boolean)) }
    attr_accessor :always

    sig { params(key: Symbol).returns(T.nilable(T.any(String, Schema::Thing))) }
    def [](key)
      @_extra[key]
    end

    sig do
      params(
        key: Symbol,
        value: T.nilable(T.any(String, Schema::Thing))
      ).returns(T.nilable(T.any(String, Schema::Thing)))
    end
    def []=(key, value)
      @_extra[key] = value
    end
  end
end
