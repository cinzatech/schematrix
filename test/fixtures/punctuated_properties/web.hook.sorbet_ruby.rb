# typed: strict

module M
  class Schema
    module Props
      class WebHook
        ORIGINAL_KEYS = { "url" => :url }.freeze

        sig { params(url: T.nilable(String)).void }
        def initialize(url: nil)
          @url = url

          @_extra = T.let({}, T::Hash[String, T.anything])
        end

        sig { returns(T.nilable(String)) }
        attr_accessor :url

        sig { params(key: String).returns(T.anything) }
        def [](key)
          @_extra[key]
        end

        sig { params(key: String, value: T.anything).returns(T.anything) }
        def []=(key, value)
          @_extra[key] = value
        end

        sig { params(hash: T::Hash[String, T.anything]).returns(WebHook) }
        def self.from_h(hash)
          instance = new(url: hash["url"])

          hash.each do |key, value|
            next if ORIGINAL_KEYS.key?(key)

            instance[key] = value
          end
          instance
        end

        sig { returns(T::Hash[String, T.anything]) }
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
