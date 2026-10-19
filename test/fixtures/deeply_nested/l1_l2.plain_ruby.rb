module M
  class Schema
    module Props
      class L1
        module Props
          class L2
            ORIGINAL_KEYS = { "val" => :val }.freeze

            def initialize(val: nil)
              @val = val

              @_extra = {}
            end

            attr_accessor :val

            def [](key)
              @_extra[key]
            end

            def []=(key, value)
              @_extra[key] = value
            end

            def self.from_h(hash)
              instance = new(val: hash["val"])

              hash.each do |key, value|
                next if ORIGINAL_KEYS.key?(key)

                instance[key] = value
              end
              instance
            end

            def to_h
              result = {}
              result["val"] = @val unless @val.nil?
              @_extra.each { |key, value| result[key] = value }
              result
            end
          end
        end
      end
    end
  end
end
