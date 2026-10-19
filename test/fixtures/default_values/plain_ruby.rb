module M
  class Schema
    ORIGINAL_KEYS = { "color" => :color, "count" => :count }.freeze

    def initialize(color: "blue", count: 0)
      @color = color
      @count = count

      @_extra = {}
    end

    attr_accessor :color, :count

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

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

    def to_h
      result = {}
      result["color"] = @color unless @color.nil?
      result["count"] = @count unless @count.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
