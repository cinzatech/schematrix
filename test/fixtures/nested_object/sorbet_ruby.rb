# typed: strict

module M
  class Schema
    sig { params(child: T.nilable(Schema::Child)).void }
    def initialize(child: nil)
      @child = child

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.nilable(Schema::Child)) }
    attr_accessor :child

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
