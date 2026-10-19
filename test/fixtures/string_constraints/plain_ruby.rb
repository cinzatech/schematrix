module M
  class Schema
    ORIGINAL_KEYS = { "code" => :code }.freeze

    def initialize(code: nil)
      @code = code

      @_extra = {}
    end

    attr_accessor :code

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.from_h(hash)
      instance = new(code: hash["code"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["code"] = @code unless @code.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
