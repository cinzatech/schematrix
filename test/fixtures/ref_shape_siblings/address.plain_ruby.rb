module M
  module Schema
    module Props
      class Address
        def initialize(zip:, country: nil, street: nil)
          @zip = zip
          @country = country
          @street = street

          @_extra = {}
        end

        attr_accessor :zip, :country, :street

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
