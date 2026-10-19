# typed: strict

module M
  module Schema
    module Props
      class WebHook
        sig { params(url: T.nilable(String)).void }
        def initialize(url: nil)
        end

        sig { returns(T.nilable(String)) }
        def url
        end

        sig { params(url: T.nilable(String)).void }
        def url=(url)
        end

        sig { params(key: Symbol).returns(T.anything) }
        def [](key)
        end

        sig { params(key: Symbol, value: T.anything).returns(T.anything) }
        def []=(key, value)
        end
      end
    end
  end
end
