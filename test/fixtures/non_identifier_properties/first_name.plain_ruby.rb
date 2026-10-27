module M
  class Schema
    module Props
      class FirstName
        ORIGINAL_KEYS = { "k" => :k }.freeze

        def initialize(k: nil)
          @k = k

          @_extra = {}
        end

        attr_accessor :k

        def [](key)
          @_extra[key]
        end

        def []=(key, value)
          @_extra[key] = value
        end

        def self.from_h(hash)
          instance = new(k: hash["k"])

          hash.each do |key, value|
            next if ORIGINAL_KEYS.key?(key)

            instance[key] = value
          end
          instance
        end

        def to_h
          result = {}
          result["k"] = @k unless @k.nil?
          @_extra.each { |key, value| result[key] = value }
          result
        end
      end
    end
  end
end
