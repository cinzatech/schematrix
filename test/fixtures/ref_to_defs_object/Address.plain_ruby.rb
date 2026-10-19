module M
  module Schema
    module Defs
      class Address
        def initialize(city: nil)
          @city = city

          @_extra = {}
        end

        attr_accessor :city

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
