module M
  class Schema
    ORIGINAL_KEYS = { "tags" => :tags }.freeze

    def initialize(tags: nil)
      @tags = tags

      @_extra = {}
    end

    attr_accessor :tags

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.from_h(hash)
      instance = new(tags: hash["tags"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["tags"] = @tags unless @tags.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
