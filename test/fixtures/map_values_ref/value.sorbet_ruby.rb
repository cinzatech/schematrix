# typed: strict

module M
  class Schema
    module Defs
      class Value
        ORIGINAL_KEYS = { "v" => :v }.freeze

        sig { params(v: T.nilable(String)).void }
        def initialize(v: nil)
          @v = v

          @_extra = T.let({}, T::Hash[String, T.anything])
        end

        sig { returns(T.nilable(String)) }
        attr_accessor :v

        sig { params(key: String).returns(T.anything) }
        def [](key)
          @_extra[key]
        end

        sig { params(key: String, value: T.anything).returns(T.anything) }
        def []=(key, value)
          @_extra[key] = value
        end

        sig { params(hash: T::Hash[String, T.anything]).returns(Value) }
        def self.from_h(hash)
          instance = new(v: hash["v"])

          hash.each do |key, value|
            next if ORIGINAL_KEYS.key?(key)

            instance[key] = value
          end
          instance
        end

        sig { returns(T::Hash[String, T.anything]) }
        def to_h
          result = {}
          result["v"] = @v unless @v.nil?
          @_extra.each { |key, value| result[key] = value }
          result
        end
      end
    end
  end
end
