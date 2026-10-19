module M
  class Schema
    ORIGINAL_KEYS = { "vars" => :vars }.freeze

    def initialize(vars: nil)
      @vars = vars

      @_extra = {}
    end

    attr_accessor :vars

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.coerce_vars(value)
      return value unless value.is_a?(Hash)

      value.transform_values do |entry|
        if entry.is_a?(M::Schema::Defs::Value)
          entry.to_h
        elsif entry.is_a?(Hash)
          M::Schema::Defs::Value.from_h(entry)
        else
          entry
        end
      end
    end

    def self.from_h(hash)
      instance = new(vars: coerce_vars(hash["vars"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["vars"] = self.class.coerce_vars(@vars) unless @vars.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
