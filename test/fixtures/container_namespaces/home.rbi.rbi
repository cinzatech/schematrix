# typed: strict

module M
  class Schema
    module Props
      class Home
        ORIGINAL_KEYS = { "street" => :street }.freeze

        sig { params(street: T.nilable(String)).void }
        def initialize(street: nil)
        end

        sig { returns(T.nilable(String)) }
        def street
        end

        sig { params(street: T.nilable(String)).void }
        def street=(street)
        end

        sig { params(key: String).returns(T.anything) }
        def [](key)
        end

        sig { params(key: String, value: T.anything).returns(T.anything) }
        def []=(key, value)
        end

        sig { params(hash: T::Hash[String, T.anything]).returns(Home) }
        def self.from_h(hash)
        end

        sig { returns(T::Hash[String, T.anything]) }
        def to_h
        end
      end
    end
  end
end
