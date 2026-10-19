module M
  module Schema
    module Props
      class Home
        def initialize(street: nil)
          @street = street

          @_extra = {}
        end

        attr_accessor :street

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
