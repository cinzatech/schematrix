# typed: strict

module M
  class Schema
    sig { params(name: T.nilable(String), code: T.nilable(String)).void }
    def initialize(name: nil, code: nil)
    end

    sig { returns(T.nilable(String)) }
    def name
    end

    sig { params(name: T.nilable(String)).void }
    def name=(name)
    end

    sig { returns(T.nilable(String)) }
    def code
    end

    sig { params(code: T.nilable(String)).void }
    def code=(code)
    end

    sig { params(key: Symbol).returns(T.nilable(Float)) }
    def [](key)
    end

    sig do
      params(key: Symbol, value: T.nilable(Float)).returns(T.nilable(Float))
    end
    def []=(key, value)
    end
  end
end
