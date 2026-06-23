module Schematrix
  # Object-type schema
  class Object
    def initialize
      @properties = {}
    end

    attr_reader :properties

    def add_property(name, schema)
      @properties[name] = schema
    end
  end
end
