module M
  class Schema
    ORIGINAL_KEYS = { "status" => :status }.freeze

    def initialize(status: nil)
      @status = status

      @_extra = {}
    end

    attr_accessor :status

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.from_h(hash)
      instance = new(status: hash["status"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["status"] = @status unless @status.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
