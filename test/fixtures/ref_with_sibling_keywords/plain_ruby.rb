module M
  class Schema
    ORIGINAL_KEYS = { "anchor" => :anchor }.freeze

    def initialize(anchor: "myAnchor")
      @anchor = anchor

      @_extra = {}
    end

    attr_accessor :anchor

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.from_h(hash)
      instance = new
      instance.anchor = hash["anchor"] if hash.key?("anchor")

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["anchor"] = @anchor unless @anchor.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
