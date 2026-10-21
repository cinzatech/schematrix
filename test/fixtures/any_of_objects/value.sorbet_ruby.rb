# typed: strict

module M
  class Schema
    module Props
      class Value
        extend T::Sig

        ORIGINAL_KEYS =
          T.let(
            { "name" => :name, "age" => :age }.freeze,
            T::Hash[String, Symbol]
          )

        sig { params(name: T.untyped, age: T.untyped).void }
        def initialize(name: nil, age: nil)
          @name = name
          @age = age

          @_extra = T.let({}, T::Hash[String, T.anything])
        end

        sig { returns(T.untyped) }
        attr_accessor :name

        sig { returns(T.untyped) }
        attr_accessor :age

        sig { params(key: String).returns(T.anything) }
        def [](key)
          @_extra[key]
        end

        sig { params(key: String, value: T.anything).returns(T.anything) }
        def []=(key, value)
          @_extra[key] = value
        end

        sig { params(hash: T::Hash[String, T.untyped]).returns(Value) }
        def self.from_h(hash)
          instance = new(name: hash["name"], age: hash["age"])

          hash.each do |key, value|
            next if ORIGINAL_KEYS.key?(key)

            instance[key] = value
          end
          instance
        end

        sig { returns(T::Hash[String, T.untyped]) }
        def to_h
          result = {}
          result["name"] = @name unless @name.nil?
          result["age"] = @age unless @age.nil?
          @_extra.each { |key, value| result[key] = value }
          result
        end
      end
    end
  end
end
