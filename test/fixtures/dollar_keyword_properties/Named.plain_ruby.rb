module M
  class Schema
    module Defs
      class Named
        ORIGINAL_KEYS = { "tag" => :tag }.freeze

        def initialize(tag: nil)
          @tag = tag

          @_extra = {}
        end

        attr_accessor :tag

        def [](key)
          @_extra[key]
        end

        def []=(key, value)
          @_extra[key] = value
        end

        def self.from_h(hash)
          instance = new(tag: hash["tag"])

          hash.each do |key, value|
            next if ORIGINAL_KEYS.key?(key)

            instance[key] = value
          end
          instance
        end

        def to_h
          result = {}
          result["tag"] = @tag unless @tag.nil?
          @_extra.each { |key, value| result[key] = value }
          result
        end
      end
    end
  end
end
