# typed: strict

module M
  class Schema
    sig do
      params(
        example_com: T.nilable(String),
        web_hook: T.nilable(Schema::Props::WebHook)
      ).void
    end
    def initialize(example_com: nil, web_hook: nil)
    end

    sig { returns(T.nilable(String)) }
    def example_com
    end

    sig { params(example_com: T.nilable(String)).void }
    def example_com=(example_com)
    end

    sig { returns(T.nilable(Schema::Props::WebHook)) }
    def web_hook
    end

    sig { params(web_hook: T.nilable(Schema::Props::WebHook)).void }
    def web_hook=(web_hook)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
