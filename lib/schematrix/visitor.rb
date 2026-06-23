require 'set'

require_relative 'array_schema'
require_relative 'object_schema'
require_relative 'schema'

module Schematrix
  TYPE_ARRAY = 'array'
  TYPE_BOOLEAN = 'boolean'
  TYPE_INTEGER = 'integer'
  TYPE_NULL = 'null'
  TYPE_NUMBER = 'number'
  TYPE_OBJECT = 'object'
  TYPE_STRING = 'string'

  # Vsitor for a JSON Schema, visits the whole schema document tree
  class Visitor
    def initialize
      @path = []
      @objects = {}
    end

    def compile(schema)
      visit_schema(schema, required: false)

      @objects
    end

    private

    def visit_schema(node, required:)
      required_properties = Set.new(node['required'])
      properties = node['properties']
      type = node['type']
      enum = node['enum']
      items = node['items']

      case type
      when TYPE_ARRAY
        Schematrix::ArraySchema.new(type:, items:, required:, enum:)
      when TYPE_BOOLEAN, TYPE_INTEGER, TYPE_NULL, TYPE_NUMBER, TYPE_STRING
        Schematrix::Schema.new(type:, required:, enum:)
      when TYPE_OBJECT
        object = Schematrix::ObjectSchema.new
        @objects[@path.join('/')] = object

        properties.each do |name, body|
          @path.push(name)
          schema = visit_schema(body, required: required_properties.include?(name))
          @path.pop
          object.add_property(name, schema) unless schema.nil?
        end

        object
      else
        raise "Unknown type #{type}" if @strict_mode
      end
    end
  end
end
