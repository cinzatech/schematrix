# typed: strict

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS =
      T.let(
        {
          "x\#{1+1}y" => :x__1_1_y,
          "back\\slash" => :back_slash,
          "a\"b" => :a_b
        }.freeze,
        T::Hash[String, Symbol]
      )

    sig do
      params(
        x__1_1_y: T.nilable(Integer),
        back_slash: T.nilable(String),
        a_b: T.nilable(String)
      ).void
    end
    def initialize(x__1_1_y: nil, back_slash: nil, a_b: nil)
      @x__1_1_y = x__1_1_y
      @back_slash = back_slash
      @a_b = a_b

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(Integer)) }
    attr_accessor :x__1_1_y

    sig { returns(T.nilable(String)) }
    attr_accessor :back_slash

    sig { returns(T.nilable(String)) }
    attr_accessor :a_b

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
      instance =
        new(
          x__1_1_y: hash["x\#{1+1}y"],
          back_slash: hash["back\\slash"],
          a_b: hash["a\"b"]
        )

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      result = {}
      result["x\#{1+1}y"] = @x__1_1_y unless @x__1_1_y.nil?
      result["back\\slash"] = @back_slash unless @back_slash.nil?
      result["a\"b"] = @a_b unless @a_b.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
