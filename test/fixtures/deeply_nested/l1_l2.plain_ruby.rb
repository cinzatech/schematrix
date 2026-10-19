module M
  module Schema
    module Props
      module L1
        module Props
          class L2
            def initialize(val: nil)
              @val = val

              @_extra = {}
            end

            attr_accessor :val

            def [](key)
              @_extra[key]
            end

            def []=(key, value)
              @_extra[key] = value
            end
          end
        end
      end
    end
  end
end
