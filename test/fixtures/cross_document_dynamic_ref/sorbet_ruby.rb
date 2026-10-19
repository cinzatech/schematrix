# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "code" => :code }.freeze

    sig { params(code: T.nilable(String)).void }
    def initialize(code: nil)
      @code = code

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :code

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
      instance = new(code: hash["code"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
      result = {}
      result["code"] = @code unless @code.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
