module M
  class Schema
    ORIGINAL_KEYS = {
      "flag" => :flag,
      "dead" => :dead,
      "sibling" => :sibling
    }.freeze

    def initialize(flag: nil, dead: nil, sibling: nil)
      @flag = flag
      @dead = dead
      @sibling = sibling

      @_extra = {}
    end

    attr_accessor :flag, :dead, :sibling

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.from_h(hash)
      instance =
        new(flag: hash["flag"], dead: hash["dead"], sibling: hash["sibling"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["flag"] = @flag unless @flag.nil?
      result["dead"] = @dead unless @dead.nil?
      result["sibling"] = @sibling unless @sibling.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
