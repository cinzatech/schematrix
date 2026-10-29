require_relative "coercion_helper"

module M
  class Schema
    ORIGINAL_KEYS = { "name" => :name, "child" => :child }.freeze

    def initialize(name:, child: nil)
      @name = name
      @child = child

      @_extra = {}
    end

    attr_accessor :name, :child

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.coerce_child(value)
      ::M::CoercionHelper.coerce_spec(value, [:class, M::Schema::Props::Child])
    end

    def self.from_h(hash)
      instance = new(name: hash["name"], child: coerce_child(hash["child"]))

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["name"] = @name unless @name.nil?
      result["child"] = self.class.coerce_child(@child) unless @child.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
