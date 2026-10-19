# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = {
      "flag" => :flag,
      "dead" => :dead,
      "sibling" => :sibling
    }.freeze

    sig do
      params(
        flag: T.anything,
        dead: T.nilable(T.noreturn),
        sibling: T.nilable(String)
      ).void
    end
    def initialize(flag: nil, dead: nil, sibling: nil)
    end

    sig { returns(T.anything) }
    def flag
    end

    sig { params(flag: T.anything).void }
    def flag=(flag)
    end

    sig { returns(T.nilable(T.noreturn)) }
    def dead
    end

    sig { params(dead: T.nilable(T.noreturn)).void }
    def dead=(dead)
    end

    sig { returns(T.nilable(String)) }
    def sibling
    end

    sig { params(sibling: T.nilable(String)).void }
    def sibling=(sibling)
    end

    sig { params(key: String).returns(T.anything) }
    def [](key)
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
    end
  end
end
