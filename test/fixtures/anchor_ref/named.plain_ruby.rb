module M
  class Schema
    module Defs
      class Named
        ORIGINAL_KEYS = { "name" => :name }.freeze

        def initialize(name: nil)
          @name = name

          @_extra = {}
        end

        attr_accessor :name

        def [](key)
          @_extra[key]
        end

        def []=(key, value)
          @_extra[key] = value
        end

        def self.from_h(hash)
          instance = new(name: hash["name"])

          hash.each do |key, value|
            next if ORIGINAL_KEYS.key?(key)

            instance[key] = value
          end
          instance
        end

        def to_h
          result = {}
          result["name"] = @name unless @name.nil?
          @_extra.each { |key, value| result[key] = value }
          result
        end
      end
    end
  end
end
