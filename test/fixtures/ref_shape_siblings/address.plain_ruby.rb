module M
  class Schema
    module Props
      class Address
        ORIGINAL_KEYS = {
          "zip" => :zip,
          "country" => :country,
          "street" => :street
        }.freeze

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

        def self.from_h(hash)
          instance =
            new(
              zip: hash["zip"],
              country: hash["country"],
              street: hash["street"]
            )

          hash.each do |key, value|
            next if ORIGINAL_KEYS.key?(key)

            instance[key] = value
          end
          instance
        end

        def to_h
          result = {}
          result["zip"] = @zip unless @zip.nil?
          result["country"] = @country unless @country.nil?
          result["street"] = @street unless @street.nil?
          @_extra.each { |key, value| result[key] = value }
          result
        end
      end
    end
  end
end
