module M
  class Schema
    ORIGINAL_KEYS = { "meta" => :meta }.freeze

    def initialize(meta: nil)
      @meta = meta

      @_extra = {}
    end

    attr_accessor :meta

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.coerce_meta(value)
      if value.is_a?(M::Schema::Props::Meta)
        value.to_h
      elsif value.is_a?(Hash)
        M::Schema::Props::Meta.from_h(value)
      else
        value
      end
    end

    def self.from_h(hash)
      instance = new(meta: coerce_meta(hash["meta"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["meta"] = self.class.coerce_meta(@meta) unless @meta.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
