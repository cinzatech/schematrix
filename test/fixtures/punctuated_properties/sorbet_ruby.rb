# typed: strict

module M
  class Schema
    sig do
      params(
        example_com: T.nilable(String),
        web_hook: T.nilable(Schema::WebHook)
      ).void
    end
    def initialize(example_com: nil, web_hook: nil)
      @example_com = example_com
      @web_hook = web_hook

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :example_com

    sig { returns(T.nilable(Schema::WebHook)) }
    attr_accessor :web_hook

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end
  end
end
