module M
  class Schema
    ORIGINAL_KEYS = { "data" => :data }.freeze

    def initialize(data: nil)
      @data = data

      @_extra = {}
    end

    attr_accessor :data

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.from_h(hash)
      instance = new(data: hash["data"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["data"] = @data unless @data.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
