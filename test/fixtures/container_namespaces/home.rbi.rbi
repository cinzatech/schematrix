# typed: strict

module M
  module Schema
    module Props
      class Home
        sig { params(street: T.nilable(String)).void }
        def initialize(street: nil)
        end

        sig { returns(T.nilable(String)) }
        def street
        end

        sig { params(street: T.nilable(String)).void }
        def street=(street)
        end

        sig { params(key: Symbol).returns(T.anything) }
        def [](key)
        end

        sig { params(key: Symbol, value: T.anything).returns(T.anything) }
        def []=(key, value)
        end
      end
    end
  end
end
