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
      default = node['default']
      description = node['description']

      case type
      when TYPE_ARRAY
        items = visit_subtree('items', node)
        Schemas::ArraySchema.new(type:, items:, required:, enum:, default:)
      when TYPE_BOOLEAN, TYPE_INTEGER, TYPE_NULL, TYPE_NUMBER, TYPE_STRING
        Schemas::Schema.new(type:, required:, enum:, default:)
      when TYPE_OBJECT
        additional_properties = visit_subtree('additionalProperties', node)

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

    # Visit subtrees other than properties, like items or additionalProperties,
    # that contain nested schema definition. It will store object definitions on
    # a nested path by the name of the branch being visited.
    def visit_subtree(branch_name, node)
      branch = node[branch_name]
      return nil if branch.nil?

      @path.push(branch_name)
      schema = visit_schema(branch)
      @path.pop

      schema
    end
  end
end
