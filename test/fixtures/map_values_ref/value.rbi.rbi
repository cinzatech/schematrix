# typed: strict

module M
  class Schema
    module Defs
      class Value
        ORIGINAL_KEYS = { "v" => :v }.freeze

        sig { params(v: T.nilable(String)).void }
        def initialize(v: nil)
        end

        sig { returns(T.nilable(String)) }
        def v
        end

        sig { params(v: T.nilable(String)).void }
        def v=(v)
        end

        sig { params(key: String).returns(T.anything) }
        def [](key)
        end

        sig { params(key: String, value: T.anything).returns(T.anything) }
        def []=(key, value)
        end

        sig { params(hash: T::Hash[String, T.anything]).returns(Value) }
        def self.from_h(hash)
        end

        sig { returns(T::Hash[String, T.anything]) }
        def to_h
        end
      end
    end
  end
end
