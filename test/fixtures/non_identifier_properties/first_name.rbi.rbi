# typed: strict

module M
  class Schema
    module Props
      class FirstName
        ORIGINAL_KEYS = { "k" => :k }.freeze

        sig { params(k: T.nilable(String)).void }
        def initialize(k: nil)
        end

        sig { returns(T.nilable(String)) }
        def k
        end

        sig { params(k: T.nilable(String)).void }
        def k=(k)
        end

        sig { params(key: String).returns(T.anything) }
        def [](key)
        end

        sig { params(key: String, value: T.anything).returns(T.anything) }
        def []=(key, value)
        end

        sig { params(hash: T::Hash[String, T.anything]).returns(FirstName) }
        def self.from_h(hash)
        end

        sig { returns(T::Hash[String, T.anything]) }
        def to_h
        end
      end
    end
  end
end
