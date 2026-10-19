# typed: strict

module M
  module Schema
    module Props
      module L1
        module Props
          class L2
            sig { params(val: T.nilable(String)).void }
            def initialize(val: nil)
            end

            sig { returns(T.nilable(String)) }
            def val
            end

            sig { params(val: T.nilable(String)).void }
            def val=(val)
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
  end
end
