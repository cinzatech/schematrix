# typed: strict

module M
  class Schema
    module Props
      class Value
        ORIGINAL_KEYS = { "name" => :name, "age" => :age }.freeze

        sig { params(name: T.anything, age: T.anything).void }
        def initialize(name: nil, age: nil)
        end

        sig { returns(T.anything) }
        def name
        end

        sig { params(name: T.anything).void }
        def name=(name)
        end

        sig { returns(T.anything) }
        def age
        end

        sig { params(age: T.anything).void }
        def age=(age)
        end

        sig { params(key: String).returns(T.anything) }
        def [](key)
        end

        sig { params(key: String, value: T.anything).returns(T.anything) }
        def []=(key, value)
        end

        sig { params(hash: T::Hash[String, T.anything]).returns(Value) }
        def self.from_h(hash)
        end

        sig { returns(T::Hash[String, T.anything]) }
        def to_h
        end
      end
    end
  end
end
