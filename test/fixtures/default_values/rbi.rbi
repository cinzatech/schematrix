# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "color" => :color, "count" => :count }.freeze

    sig { params(color: T.nilable(String), count: T.nilable(Integer)).void }
    def initialize(color: "blue", count: 0)
    end

    sig { returns(T.nilable(String)) }
    def color
    end

    sig { params(color: T.nilable(String)).void }
    def color=(color)
    end

    sig { returns(T.nilable(Integer)) }
    def count
    end

    sig { params(count: T.nilable(Integer)).void }
    def count=(count)
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
