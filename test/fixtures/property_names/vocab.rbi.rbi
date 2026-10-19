# typed: strict

module M
  module Schema
    module Props
      class Vocab
        sig { void }
        def initialize
        end

        sig { params(key: Symbol).returns(T.nilable(T::Boolean)) }
        def [](key)
        end

        sig do
          params(key: Symbol, value: T.nilable(T::Boolean)).returns(
            T.nilable(T::Boolean)
          )
        end
        def []=(key, value)
        end
      end
    end
  end
end
