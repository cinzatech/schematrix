module M
  module Schema
    module Defs
      class Value
        def initialize(v: nil)
          @v = v

          @_extra = {}
        end

        attr_accessor :v

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
