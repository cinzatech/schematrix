module M
  class Schema
    ORIGINAL_KEYS = {
      "$id" => :id,
      "if" => :if_,
      "then" => :then_,
      "$defs" => :defs,
      "named" => :named
    }.freeze

    def initialize(id: nil, if_: nil, then_: nil, defs: nil, named: nil)
      @id = id
      @if_ = if_
      @then_ = then_
      @defs = defs
      @named = named

      @_extra = {}
    end

    attr_accessor :id, :if_, :then_, :defs, :named

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.coerce_defs(value)
      if value.is_a?(M::Schema::Props::Defs)
        value.to_h
      elsif value.is_a?(Hash)
        M::Schema::Props::Defs.from_h(value)
      else
        value
      end
    end

    def self.coerce_named(value)
      if value.is_a?(M::Schema::Defs::Named)
        value.to_h
      elsif value.is_a?(Hash)
        M::Schema::Defs::Named.from_h(value)
      else
        value
      end
    end

    def self.from_h(hash)
      instance =
        new(
          id: hash["$id"],
          if_: hash["if"],
          then_: hash["then"],
          defs: coerce_defs(hash["$defs"]),
          named: coerce_named(hash["named"])
        )

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["$id"] = @id unless @id.nil?
      result["if"] = @if_ unless @if_.nil?
      result["then"] = @then_ unless @then_.nil?
      result["$defs"] = self.class.coerce_defs(@defs) unless @defs.nil?
      result["named"] = self.class.coerce_named(@named) unless @named.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
