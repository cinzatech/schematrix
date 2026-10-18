require "uri"

module Schematrix
  TYPE_ARRAY = "array"
  TYPE_BOOLEAN = "boolean"
  # Pseudo type marking the "false" schema (no valid instance). Not a
  # JSON Schema type name: templates map it to their bottom type.
  TYPE_BOTTOM = "bottom"
  TYPE_INTEGER = "integer"
  TYPE_NULL = "null"
  TYPE_NUMBER = "number"
  TYPE_OBJECT = "object"
  TYPE_STRING = "string"

  Schema =
    Data.define(
      :additional_properties,
      :default,
      :description,
      :enum,
      :items,
      :properties,
      :ref,
      :required,
      :title,
      :type,
    )

  Schema::Empty =
    Schema.new(
      additional_properties: nil,
      default: nil,
      enum: nil,
      items: nil,
      properties: nil,
      description: nil,
      ref: nil,
      required: nil,
      title: nil,
      type: Set.new,
    )

  # The "false" schema accepts no instance at all. It types as a
  # bottom type where the target language has one (T.noreturn in
  # Sorbet), untyped elsewhere.
  Schema::Bottom =
    Schema.new(
      additional_properties: nil,
      default: nil,
      enum: nil,
      items: nil,
      properties: nil,
      description: nil,
      ref: nil,
      required: nil,
      title: nil,
      type: Set[TYPE_BOTTOM],
    )

  # Visits a single schema subtree rooted at the given locator. When it
  # finds a $ref it resolves the reference through the document store to
  # decide how to represent it, and records edges to object schemas so
  # their classes get generated. It never visits ref targets itself: the
  # caller (see Compiler) decides when and whether to do that.
  class Visitor
    # The findings of a visit: the object schemas the subtree contains
    # by locator, and edges to object schemas living elsewhere that it
    # references.
    attr_reader :objects, :edges

    def initialize(locator, store)
      @locator = locator
      @store = store
      @objects = {}
      @edges = []

      @fragment_path = locator.fragment.split("/")
      @name = @fragment_path.pop || "" # document root is nameless
    end

    def compile(node)
      visit_schema(@name, node, required: false)

      self
    end

    private

    def visit_schema(name, node, required: true)
      @fragment_path.push(name)

      # JSON Schema allows "true" as a catch-all
      if node.is_a? TrueClass
        @objects[current_locator] = Schema::Empty
        return Schema::Empty
      end

      # JSON Schema "false" accepts nothing: no class, bottom type
      return Schema::Bottom if node.is_a?(FalseClass)

      node, ref = resolve_reference(node)

      type = Set.new(Array(node["type"]))
      enum = node["enum"]
      default = node["default"]
      title = node["title"]
      description = node["description"]
      items = visit_subtree("items", node)
      additional_properties = visit_subtree("additionalProperties", node)
      required_properties = Set.new(node["required"])

      @fragment_path.push("properties")
      pairs =
        node["properties"]&.filter_map do |prop_name, body|
          schema =
            visit_schema(
              prop_name,
              body,
              required: required_properties.include?(prop_name),
            )
          [prop_name, schema]
        end
      properties = pairs&.to_h
      @fragment_path.pop

      schema =
        Schema.new(
          additional_properties:,
          default:,
          description:,
          enum:,
          items:,
          properties:,
          ref:,
          required:,
          title:,
          type:,
        )

      @objects[current_locator] = schema if ref.nil? &&
        type.include?(TYPE_OBJECT)

      schema
    ensure
      @fragment_path.pop
    end

    # Resolves a $ref, if present, by following the chain of references
    # to its final target node:
    # - object target: keep the node as-is and return the target's locator
    #   as ref, recording the edge so its class is generated.
    # - scalar target: return the target node itself so its type
    #   information is compiled in place of the reference, and no ref.
    # TODO: merge keywords when a $ref has sibling overrides
    def resolve_reference(node)
      reference = node["$ref"]
      return node, nil if reference.nil?

      target, locator = final_target(@locator, reference)
      return node, nil if target.nil?

      if Array(target["type"]).include?(TYPE_OBJECT)
        @edges << locator
        [node, locator]
      else
        # Inline the target's keywords, local siblings win over them
        [target.merge(node.except("$ref")), nil]
      end
    end

    # Follows chains of pure references to the final node, guarding
    # against cycles. Returns the node and its locator.
    def final_target(base, reference, seen = Set.new)
      locator = URI.join(base, reference)
      locator.fragment = "/" if locator.fragment.nil?

      return nil, nil unless seen.add?(locator.to_s)

      node = @store.node_at(locator)
      reference = node.is_a?(Hash) ? node["$ref"] : nil
      return node, locator if reference.nil?

      target, target_locator = final_target(locator, reference, seen)
      target ? [target, target_locator] : [node, locator]
    end

    # Visit subtrees (other than properties), like items or
    # additionalProperties, that contain nested schema definition. It
    # will store object definitions on a nested path by the name of the
    # branch being visited. additionalProperties: false is the one
    # closed shape: no catch-all, so it contributes nil; a false items
    # branch keeps its bottom schema so templates can tell a closed
    # tail from an absent one.
    def visit_subtree(branch_name, node)
      branch = node[branch_name]
      return nil if branch.nil?
      if branch.is_a?(FalseClass) && branch_name == "additionalProperties"
        return nil
      end

      visit_schema(branch_name, branch)
    end

    def current_locator
      fragment = @fragment_path.join("/")
      locator = @locator.dup
      locator.fragment = fragment.empty? ? "/" : fragment
      locator.to_s
    end
  end
end
