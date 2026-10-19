# typed: strict

module M
  module Schema
    module Defs
      class Value
        sig { params(v: T.nilable(String)).void }
        def initialize(v: nil)
        end

        sig { returns(T.nilable(String)) }
        def v
        end

        sig { params(v: T.nilable(String)).void }
        def v=(v)
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
