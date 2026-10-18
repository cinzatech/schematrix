# typed: strict

module M
  class Schema
    sig { params(name: T.nilable(String), legacy: T.nilable(T.noreturn)).void }
    def initialize(name: nil, legacy: nil)
    end

    sig { returns(T.nilable(String)) }
    def name
    end

    sig { params(name: T.nilable(String)).void }
    def name=(name)
    end

    sig { returns(T.nilable(T.noreturn)) }
    def legacy
    end

    sig { params(legacy: T.nilable(T.noreturn)).void }
    def legacy=(legacy)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
