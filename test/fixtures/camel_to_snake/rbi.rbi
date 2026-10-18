# typed: strict

module M
  class Schema
    sig do
      params(first_name: T.nilable(String), last_name: T.nilable(String)).void
    end
    def initialize(first_name: nil, last_name: nil)
    end

    sig { returns(T.nilable(String)) }
    def first_name
    end

    sig { params(first_name: T.nilable(String)).void }
    def first_name=(first_name)
    end

    sig { returns(T.nilable(String)) }
    def last_name
    end

    sig { params(last_name: T.nilable(String)).void }
    def last_name=(last_name)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
