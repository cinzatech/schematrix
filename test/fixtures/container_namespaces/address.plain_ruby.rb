module M
  class Schema
    module Defs
      class Address
        ORIGINAL_KEYS = { "city" => :city }.freeze

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

        def self.from_h(hash)
          instance = new(city: hash["city"])

          hash.each do |key, value|
            next if ORIGINAL_KEYS.key?(key)

            instance[key] = value
          end
          instance
        end

        def to_h
          result = {}
          result["city"] = @city unless @city.nil?
          @_extra.each { |key, value| result[key] = value }
          result
        end
      end
    end
  end
end
