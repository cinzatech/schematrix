module M
  class Schema
    ORIGINAL_KEYS = {
      "x\#{1+1}y" => :x__1_1_y,
      "back\\slash" => :back_slash,
      "a\"b" => :a_b
    }.freeze

    def initialize(x__1_1_y: nil, back_slash: nil, a_b: nil)
      @x__1_1_y = x__1_1_y
      @back_slash = back_slash
      @a_b = a_b

      @_extra = {}
    end

    attr_accessor :x__1_1_y, :back_slash, :a_b

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

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
