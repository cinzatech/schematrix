# typed: strict

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS =
      T.let(
        { "color" => :color, "count" => :count }.freeze,
        T::Hash[String, Symbol]
      )

    sig { params(color: T.nilable(String), count: T.nilable(Integer)).void }
    def initialize(color: "blue", count: 0)
      @color = color
      @count = count

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :color

    sig { returns(T.nilable(Integer)) }
    attr_accessor :count

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
    def self.from_h(hash)
      instance = new
      instance.color = hash["color"] if hash.key?("color")
      instance.count = hash["count"] if hash.key?("count")

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      result = {}
      result["color"] = @color unless @color.nil?
      result["count"] = @count unless @count.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
