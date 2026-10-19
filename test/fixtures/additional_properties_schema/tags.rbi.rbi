# typed: strict

module M
  module Schema
    module Props
      class Tags
        sig { void }
        def initialize
        end

        sig { params(key: Symbol).returns(T.nilable(String)) }
        def [](key)
        end

        sig do
          params(key: Symbol, value: T.nilable(String)).returns(
            T.nilable(String)
          )
        end
        def []=(key, value)
        end
      end
    end
  end
end
