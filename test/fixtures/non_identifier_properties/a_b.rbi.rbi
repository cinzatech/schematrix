# typed: strict

module M
  class Schema
    module Props
      class AB
        ORIGINAL_KEYS = { "z" => :z }.freeze

        sig { params(z: T.nilable(String)).void }
        def initialize(z: nil)
        end

        sig { returns(T.nilable(String)) }
        def z
        end

        sig { params(z: T.nilable(String)).void }
        def z=(z)
        end

        sig { params(key: String).returns(T.anything) }
        def [](key)
        end

        sig { params(key: String, value: T.anything).returns(T.anything) }
        def []=(key, value)
        end

        sig { params(hash: T::Hash[String, T.anything]).returns(AB) }
        def self.from_h(hash)
        end

        sig { returns(T::Hash[String, T.anything]) }
        def to_h
        end
      end
    end
  end
end
