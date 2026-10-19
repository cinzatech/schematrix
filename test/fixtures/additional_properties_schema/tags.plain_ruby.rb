module M
  module Schema
    module Props
      class Tags
        def initialize
          @_extra = {}
        end

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
