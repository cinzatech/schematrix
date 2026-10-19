module M
  module Schema
    module Props
      class WebHook
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
      end
    end
  end
end
