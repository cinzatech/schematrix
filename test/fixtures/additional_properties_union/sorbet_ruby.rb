# typed: strict

module M
  class Schema
    sig { params(name: T.nilable(String), code: T.nilable(String)).void }
    def initialize(name: nil, code: nil)
      @name = name
      @code = code

      @_extra = T.let({}, T::Hash[Symbol, T.nilable(Float)])
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :name

    sig { returns(T.nilable(String)) }
    attr_accessor :code

    sig { params(key: Symbol).returns(T.nilable(Float)) }
    def [](key)
      @_extra[key]
    end

    sig do
      params(key: Symbol, value: T.nilable(Float)).returns(T.nilable(Float))
    end
    def []=(key, value)
      @_extra[key] = value
    end
  end
end
