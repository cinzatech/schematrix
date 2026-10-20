# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = {
      "example.com" => :example_com,
      "web.hook" => :web_hook
    }.freeze

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

    sig { params(key: String).returns(T.anything) }
    def [](key)
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end

    sig { params(value: T.anything, klass: T.anything).returns(T.anything) }
    def self.coerce_class_slot(value, klass)
    end

    sig { params(value: T.anything, klass: T.anything).returns(T.anything) }
    def self.coerce_array_slot(value, klass)
    end

    sig { params(value: T.anything, klass: T.anything).returns(T.anything) }
    def self.coerce_map_slot(value, klass)
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_web_hook(value)
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
    end
  end
end
