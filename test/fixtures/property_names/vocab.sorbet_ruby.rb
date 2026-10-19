# typed: strict

module M
  module Schema
    module Props
      class Vocab
        sig { void }
        def initialize
          @_extra = T.let({}, T::Hash[Symbol, T.nilable(T::Boolean)])
        end

        sig { params(key: Symbol).returns(T.nilable(T::Boolean)) }
        def [](key)
          @_extra[key]
        end

        sig do
          params(key: Symbol, value: T.nilable(T::Boolean)).returns(
            T.nilable(T::Boolean)
          )
        end
        def []=(key, value)
          @_extra[key] = value
        end
      end
    end
  end
end
