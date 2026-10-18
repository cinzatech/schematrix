# typed: strict

module M
  class Schema::Tags
    sig { void }
    def initialize
    end

    sig { params(key: Symbol).returns(T.nilable(String)) }
    def [](key)
    end

    sig do
      params(key: Symbol, value: T.nilable(String)).returns(T.nilable(String))
    end
    def []=(key, value)
    end
  end
end
