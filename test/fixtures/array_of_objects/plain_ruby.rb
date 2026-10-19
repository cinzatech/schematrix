module M
  class Schema
    ORIGINAL_KEYS = { "entries" => :entries }.freeze

    def initialize(entries: nil)
      @entries = entries

      @_extra = {}
    end

    attr_accessor :entries

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.coerce_entries(value)
      return value unless value.is_a?(Array)

      value.map do |element|
        if element.is_a?(M::Schema::Props::Entries::Items)
          element.to_h
        elsif element.is_a?(Hash)
          M::Schema::Props::Entries::Items.from_h(element)
        else
          element
        end
      end
    end

    def self.from_h(hash)
      instance = new(entries: coerce_entries(hash["entries"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["entries"] = self.class.coerce_entries(
        @entries
      ) unless @entries.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
