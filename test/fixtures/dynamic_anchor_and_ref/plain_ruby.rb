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
      return value unless value.is_a?(Array)

      value.map do |element|
        if element.is_a?(M::Schema)
          element.to_h
        elsif element.is_a?(Hash)
          M::Schema.from_h(element)
        else
          element
        end
      end
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
