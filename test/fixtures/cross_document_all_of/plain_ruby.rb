module M
  class Schema
    ORIGINAL_KEYS = { "own" => :own, "kind" => :kind }.freeze

    def initialize(own: nil, kind: nil)
      @own = own
      @kind = kind

      @_extra = {}
    end

    attr_accessor :own, :kind

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.from_h(hash)
      instance = new(own: hash["own"], kind: hash["kind"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["own"] = @own unless @own.nil?
      result["kind"] = @kind unless @kind.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
