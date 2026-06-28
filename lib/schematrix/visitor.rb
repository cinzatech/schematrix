require 'set'

require_relative 'schemas/array_schema'
require_relative 'schemas/object_schema'
require_relative 'schemas/schema'

module Schematrix
  TYPE_ARRAY = 'array'
  TYPE_BOOLEAN = 'boolean'
  TYPE_INTEGER = 'integer'
  TYPE_NULL = 'null'
  TYPE_NUMBER = 'number'
  TYPE_OBJECT = 'object'
  TYPE_STRING = 'string'

  # Visitor for a JSON Schema, visits the whole schema document tree
  class Visitor
    def initialize(strict_mode: false)
      @strict_mode = strict_mode
      @path = []
      @objects = {}
    end

    def compile(schema)
      visit_schema(schema, required: false)

      @objects
    end

    private

    def visit_schema(node, required: true)
      required_properties = Set.new(node['required'])
      properties = node['properties']
      type = node['type']
      enum = node['enum']
      items = node['items']
      default = node['default']
      description = node['description']

      case type
      when TYPE_ARRAY
        Schemas::ArraySchema.new(type:, items:, required:, enum:, default:)
      when TYPE_BOOLEAN, TYPE_INTEGER, TYPE_NULL, TYPE_NUMBER, TYPE_STRING
        Schemas::Schema.new(type:, required:, enum:, default:)
      when TYPE_OBJECT
        additional_properties = visit_additional_properties(node)

        object = Schemas::ObjectSchema.new(
          additional_properties:,
          default:,
          description:,
          enum:,
          required:,
          type:
        )
        @objects[@path.join('/')] = object

        properties&.each do |name, body|
          @path.push(name)
          schema = visit_schema(body, required: required_properties.include?(name))
          @path.pop
          object.add_property(name, schema) unless schema.nil?
        end

        object
      else
        return Schemas::Schema.new(type:, required:, enum:, default:) unless enum.nil?

        raise "Unknown type #{type}" if @strict_mode
      end
    end

    def visit_additional_properties(node)
      additional_properties = node['additionalProperties']
      return nil if additional_properties.nil?

      @path.push('additionalProperties')
      schema = visit_schema(additional_properties) unless additional_properties.nil?
      @path.pop

      schema
    end
  end
end
