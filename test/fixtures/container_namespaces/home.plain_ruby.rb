module M
  class Schema
    module Props
      class Home
        ORIGINAL_KEYS = { "street" => :street }.freeze

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

        def self.from_h(hash)
          instance = new(street: hash["street"])

          hash.each do |key, value|
            next if ORIGINAL_KEYS.key?(key)

            instance[key] = value
          end
          instance
        end

        def to_h
          result = {}
          result["street"] = @street unless @street.nil?
          @_extra.each { |key, value| result[key] = value }
          result
        end
      end
    end
  end
end
