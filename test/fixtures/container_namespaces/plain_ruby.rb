module M
  class Schema
    ORIGINAL_KEYS = { "home" => :home, "alt" => :alt }.freeze

    def initialize(home: nil, alt: nil)
      @home = home
      @alt = alt

      @_extra = {}
    end

    attr_accessor :home, :alt

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.coerce_class_slot(value, klass)
      if value.is_a?(klass)
        value.to_h
      elsif value.is_a?(Hash)
        klass.from_h(value)
      else
        value
      end
    end

    def self.coerce_array_slot(value, klass)
      return value unless value.is_a?(Array)

      value.map { |element| coerce_class_slot(element, klass) }
    end

    def self.coerce_map_slot(value, klass)
      return value unless value.is_a?(Hash)

      value.transform_values { |entry| coerce_class_slot(entry, klass) }
    end

    def self.coerce_home(value)
      coerce_class_slot(value, M::Schema::Props::Home)
    end

    def self.coerce_alt(value)
      coerce_class_slot(value, M::Schema::Defs::Address)
    end

    def self.from_h(hash)
      instance =
        new(home: coerce_home(hash["home"]), alt: coerce_alt(hash["alt"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["home"] = self.class.coerce_home(@home) unless @home.nil?
      result["alt"] = self.class.coerce_alt(@alt) unless @alt.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
