require_relative "coercion_helper"

module M
  class Schema
    ORIGINAL_KEYS = { "value" => :value, "children" => :children }.freeze

    def initialize(value: nil, children: nil)
      @value = value
      @children = children

      @_extra = {}
    end

    attr_accessor :value, :children

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.coerce_children(value)
      ::M::CoercionHelper.coerce_spec(value, [:array, [:class, M::Schema]])
    end

    def self.from_h(hash)
      instance =
        new(value: hash["value"], children: coerce_children(hash["children"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["value"] = @value unless @value.nil?
      result["children"] = self.class.coerce_children(
        @children
      ) unless @children.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
