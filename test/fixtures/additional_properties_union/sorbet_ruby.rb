# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "name" => :name, "code" => :code }.freeze

    sig { params(name: T.nilable(String), code: T.nilable(String)).void }
    def initialize(name: nil, code: nil)
      @name = name
      @code = code

      @_extra = T.let({}, T::Hash[String, T.nilable(Numeric)])
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :name

    sig { returns(T.nilable(String)) }
    attr_accessor :code

    sig { params(key: String).returns(T.nilable(Numeric)) }
    def [](key)
      @_extra[key]
    end

    sig do
      params(key: String, value: T.nilable(Numeric)).returns(T.nilable(Numeric))
    end
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
      instance = new(name: hash["name"], code: hash["code"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
      result = {}
      result["name"] = @name unless @name.nil?
      result["code"] = @code unless @code.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
