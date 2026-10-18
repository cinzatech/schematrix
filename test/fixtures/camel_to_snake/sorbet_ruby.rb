# typed: strict

module M
  class Schema
    sig do
      params(first_name: T.nilable(String), last_name: T.nilable(String)).void
    end
    def initialize(first_name: nil, last_name: nil)
      @first_name = first_name
      @last_name = last_name

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :first_name

    sig { returns(T.nilable(String)) }
    attr_accessor :last_name

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
