# typed: strict

module M
  class Schema
    module Props
      class L1
        module Props
          class L2
            ORIGINAL_KEYS = { "val" => :val }.freeze

            sig { params(val: T.nilable(String)).void }
            def initialize(val: nil)
            end

            sig { returns(T.nilable(String)) }
            def val
            end

            sig { params(val: T.nilable(String)).void }
            def val=(val)
            end

            sig { params(key: String).returns(T.anything) }
            def [](key)
            end

            sig { params(key: String, value: T.anything).returns(T.anything) }
            def []=(key, value)
            end

            sig { params(hash: T::Hash[String, T.anything]).returns(L2) }
            def self.from_h(hash)
            end

            sig { returns(T::Hash[String, T.anything]) }
            def to_h
            end
          end
        end
      end
    end
  end
end
