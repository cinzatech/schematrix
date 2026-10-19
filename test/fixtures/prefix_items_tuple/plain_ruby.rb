module M
  class Schema
    ORIGINAL_KEYS = { "point" => :point }.freeze

    def initialize(point: nil)
      @point = point

      @_extra = {}
    end

    attr_accessor :point

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.from_h(hash)
      instance = new(point: hash["point"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["point"] = @point unless @point.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
