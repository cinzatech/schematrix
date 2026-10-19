# typed: strict

module M
  class Schema
    module Props
      class WebHook
        ORIGINAL_KEYS = { "url" => :url }.freeze

        sig { params(url: T.nilable(String)).void }
        def initialize(url: nil)
        end

        sig { returns(T.nilable(String)) }
        def url
        end

        sig { params(url: T.nilable(String)).void }
        def url=(url)
        end

        sig { params(key: String).returns(T.anything) }
        def [](key)
        end

        sig { params(key: String, value: T.anything).returns(T.anything) }
        def []=(key, value)
        end

        sig { params(hash: T::Hash[String, T.anything]).returns(WebHook) }
        def self.from_h(hash)
        end

        sig { returns(T::Hash[String, T.anything]) }
        def to_h
        end
      end
    end
  end
end
