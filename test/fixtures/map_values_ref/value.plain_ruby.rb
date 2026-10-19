module M
  class Schema
    module Defs
      class Value
        ORIGINAL_KEYS = { "v" => :v }.freeze

        def initialize(v: nil)
          @v = v

          @_extra = {}
        end

        attr_accessor :v

        def [](key)
          @_extra[key]
        end

        def []=(key, value)
          @_extra[key] = value
        end

        def self.from_h(hash)
          instance = new(v: hash["v"])

          hash.each do |key, value|
            next if ORIGINAL_KEYS.key?(key)

            instance[key] = value
          end
          instance
        end

        def to_h
          result = {}
          result["v"] = @v unless @v.nil?
          @_extra.each { |key, value| result[key] = value }
          result
        end
      end
    end
  end
end
