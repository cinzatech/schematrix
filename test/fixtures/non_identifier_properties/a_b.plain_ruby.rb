module M
  class Schema
    module Props
      class AB
        ORIGINAL_KEYS = { "z" => :z }.freeze

        def initialize(z: nil)
          @z = z

          @_extra = {}
        end

        attr_accessor :z

        def [](key)
          @_extra[key]
        end

        def []=(key, value)
          @_extra[key] = value
        end

        def self.from_h(hash)
          instance = new(z: hash["z"])

          hash.each do |key, value|
            next if ORIGINAL_KEYS.key?(key)

            instance[key] = value
          end
          instance
        end

        def to_h
          result = {}
          result["z"] = @z unless @z.nil?
          @_extra.each { |key, value| result[key] = value }
          result
        end
      end
    end
  end
end
