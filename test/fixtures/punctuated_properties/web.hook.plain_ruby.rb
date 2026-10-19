module M
  class Schema
    module Props
      class WebHook
        ORIGINAL_KEYS = { "url" => :url }.freeze

        def initialize(url: nil)
          @url = url

          @_extra = {}
        end

        attr_accessor :url

        def [](key)
          @_extra[key]
        end

        def []=(key, value)
          @_extra[key] = value
        end

        def self.from_h(hash)
          instance = new(url: hash["url"])

          hash.each do |key, value|
            next if ORIGINAL_KEYS.key?(key)

            instance[key] = value
          end
          instance
        end

        def to_h
          result = {}
          result["url"] = @url unless @url.nil?
          @_extra.each { |key, value| result[key] = value }
          result
        end
      end
    end
  end
end
