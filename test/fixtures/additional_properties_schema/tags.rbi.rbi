# typed: strict

module M
  class MapLike::Tags
    sig { void }
    def initialize
    end

    sig { params(key: Symbol).returns(String) }
    def [](key)
    end

    sig { params(key: Symbol, value:).returns(String) }
    def []=(key, value)
    end
  end
end
