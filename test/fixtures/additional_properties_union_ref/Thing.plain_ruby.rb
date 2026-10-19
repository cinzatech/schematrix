module M
  module Schema
    module Defs
      class Thing
        def initialize(name: nil)
          @name = name

          @_extra = {}
        end

        attr_accessor :name

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
