# typed: strict

module M
  class Schema
    module Props
      class L1
        module Props
          class L2
            extend T::Sig

            ORIGINAL_KEYS =
              T.let({ "val" => :val }.freeze, T::Hash[String, Symbol])

            sig { params(val: T.nilable(String)).void }
            def initialize(val: nil)
              @val = val

              @_extra = T.let({}, T::Hash[String, T.anything])
            end

            sig { returns(T.nilable(String)) }
            attr_accessor :val

            sig { params(key: String).returns(T.anything) }
            def [](key)
              @_extra[key]
            end

            sig { params(key: String, value: T.anything).returns(T.anything) }
            def []=(key, value)
              @_extra[key] = value
            end

            sig { params(hash: T::Hash[String, T.untyped]).returns(L2) }
            def self.from_h(hash)
              instance = new(val: hash["val"])

              hash.each do |key, value|
                next if ORIGINAL_KEYS.key?(key)

                instance[key] = value
              end
              instance
            end

            sig { returns(T::Hash[String, T.untyped]) }
            def to_h
              result = {}
              result["val"] = @val unless @val.nil?
              @_extra.each { |key, value| result[key] = value }
              result
            end
          end
        end
      end
    end
  end
end
