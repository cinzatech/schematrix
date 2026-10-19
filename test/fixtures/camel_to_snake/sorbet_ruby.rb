# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = {
      "firstName" => :first_name,
      "lastName" => :last_name
    }.freeze

    sig do
      params(first_name: T.nilable(String), last_name: T.nilable(String)).void
    end
    def initialize(first_name: nil, last_name: nil)
      @first_name = first_name
      @last_name = last_name

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :first_name

    sig { returns(T.nilable(String)) }
    attr_accessor :last_name

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
      instance = new(first_name: hash["firstName"], last_name: hash["lastName"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
      result = {}
      result["firstName"] = @first_name unless @first_name.nil?
      result["lastName"] = @last_name unless @last_name.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
