require 'set'

module Schematrix
  TYPE_ARRAY = 'array'
  TYPE_BOOLEAN = 'boolean'
  TYPE_INTEGER = 'integer'
  TYPE_NULL = 'null'
  TYPE_NUMBER = 'number'
  TYPE_OBJECT = 'object'
  TYPE_STRING = 'string'

  Schema = Data.define(
    :additional_properties,
    :default,
    :description,
    :enum,
    :items,
    :properties,
    :required,
    :type
  )

  # Visitor for a JSON Schema, visits the whole schema document tree
  class Visitor
    def initialize
      @path = []
      @objects = {}
    end

    def compile(title, schema)
      visit_schema(title, schema, required: false)

      @objects
    end

    private

    def visit_schema(name, node, required: true)
      @path.push(name)

      type = Set.new(Array(node['type']))
      enum = node['enum']
      default = node['default']
      description = node['description']
      items = visit_subtree('items', node)
      additional_properties = visit_subtree('additionalProperties', node)
      required_properties = Set.new(node['required'])
      properties = node['properties']&.map do |name, body|
        schema = visit_schema(name, body, required: required_properties.include?(name))
        [name, schema] unless schema.nil?
      end&.compact&.to_h

      schema = Schema.new(
        additional_properties:,
        properties:,
        default:,
        description:,
        enum:,
        required:,
        type:,
        items:
      )

      @objects[@path.join('/')] = schema if type.include?(TYPE_OBJECT)
      @path.pop

      schema
    end

    # Visit subtrees (other than properties), like items or additionalProperties,
    # that contain nested schema definition. It will store object definitions on
    # a nested path by the name of the branch being visited.
    def visit_subtree(branch_name, node)
      branch = node[branch_name]
      return nil if branch.nil?

      visit_schema(branch_name, branch)
    end
  end
end
