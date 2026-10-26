# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = {
      "x\#{1+1}y" => :x__1_1_y,
      "back\\slash" => :back_slash,
      "a\"b" => :a_b
    }.freeze

    sig do
      params(
        x__1_1_y: T.nilable(Integer),
        back_slash: T.nilable(String),
        a_b: T.nilable(String)
      ).void
    end
    def initialize(x__1_1_y: nil, back_slash: nil, a_b: nil)
    end

    sig { returns(T.nilable(Integer)) }
    def x__1_1_y
    end

    sig { params(x__1_1_y: T.nilable(Integer)).void }
    def x__1_1_y=(x__1_1_y)
    end

    sig { returns(T.nilable(String)) }
    def back_slash
    end

    sig { params(back_slash: T.nilable(String)).void }
    def back_slash=(back_slash)
    end

    sig { returns(T.nilable(String)) }
    def a_b
    end

    sig { params(a_b: T.nilable(String)).void }
    def a_b=(a_b)
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
