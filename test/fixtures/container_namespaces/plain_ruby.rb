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

    def self.coerce_home(value)
      if value.is_a?(M::Schema::Props::Home)
        value.to_h
      elsif value.is_a?(Hash)
        M::Schema::Props::Home.from_h(value)
      else
        value
      end
    end

    def self.coerce_alt(value)
      if value.is_a?(M::Schema::Defs::Address)
        value.to_h
      elsif value.is_a?(Hash)
        M::Schema::Defs::Address.from_h(value)
      else
        value
      end
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
