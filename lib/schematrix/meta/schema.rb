module Schematrix::Meta
  class Schema
    ORIGINAL_KEYS = {
      "definitions" => :definitions,
      "dependencies" => :dependencies,
      "$recursiveAnchor" => :recursive_anchor,
      "$recursiveRef" => :recursive_ref,
      "$id" => :id,
      "$schema" => :schema,
      "$ref" => :ref,
      "$anchor" => :anchor,
      "$dynamicRef" => :dynamic_ref,
      "$dynamicAnchor" => :dynamic_anchor,
      "$vocabulary" => :vocabulary,
      "$comment" => :comment,
      "$defs" => :defs,
      "prefixItems" => :prefix_items,
      "items" => :items,
      "contains" => :contains,
      "additionalProperties" => :additional_properties,
      "properties" => :properties,
      "patternProperties" => :pattern_properties,
      "dependentSchemas" => :dependent_schemas,
      "propertyNames" => :property_names,
      "if" => :if_,
      "then" => :then_,
      "else" => :else_,
      "allOf" => :all_of,
      "anyOf" => :any_of,
      "oneOf" => :one_of,
      "not" => :not_,
      "unevaluatedItems" => :unevaluated_items,
      "unevaluatedProperties" => :unevaluated_properties,
      "type" => :type,
      "const" => :const,
      "enum" => :enum,
      "multipleOf" => :multiple_of,
      "maximum" => :maximum,
      "exclusiveMaximum" => :exclusive_maximum,
      "minimum" => :minimum,
      "exclusiveMinimum" => :exclusive_minimum,
      "maxLength" => :max_length,
      "minLength" => :min_length,
      "pattern" => :pattern,
      "maxItems" => :max_items,
      "minItems" => :min_items,
      "uniqueItems" => :unique_items,
      "maxContains" => :max_contains,
      "minContains" => :min_contains,
      "maxProperties" => :max_properties,
      "minProperties" => :min_properties,
      "required" => :required,
      "dependentRequired" => :dependent_required,
      "title" => :title,
      "description" => :description,
      "default" => :default,
      "deprecated" => :deprecated,
      "readOnly" => :read_only,
      "writeOnly" => :write_only,
      "examples" => :examples,
      "format" => :format,
      "contentEncoding" => :content_encoding,
      "contentMediaType" => :content_media_type,
      "contentSchema" => :content_schema
    }.freeze

    def initialize(
      definitions: {},
      dependencies: {},
      recursive_anchor: nil,
      recursive_ref: nil,
      id: nil,
      schema: nil,
      ref: nil,
      anchor: nil,
      dynamic_ref: nil,
      dynamic_anchor: nil,
      vocabulary: nil,
      comment: nil,
      defs: nil,
      prefix_items: nil,
      items: nil,
      contains: nil,
      additional_properties: nil,
      properties: {},
      pattern_properties: {},
      dependent_schemas: {},
      property_names: nil,
      if_: nil,
      then_: nil,
      else_: nil,
      all_of: nil,
      any_of: nil,
      one_of: nil,
      not_: nil,
      unevaluated_items: nil,
      unevaluated_properties: nil,
      type: nil,
      const: nil,
      enum: nil,
      multiple_of: nil,
      maximum: nil,
      exclusive_maximum: nil,
      minimum: nil,
      exclusive_minimum: nil,
      max_length: nil,
      min_length: nil,
      pattern: nil,
      max_items: nil,
      min_items: nil,
      unique_items: false,
      max_contains: nil,
      min_contains: 1,
      max_properties: nil,
      min_properties: nil,
      required: [],
      dependent_required: nil,
      title: nil,
      description: nil,
      default: nil,
      deprecated: false,
      read_only: false,
      write_only: false,
      examples: nil,
      format: nil,
      content_encoding: nil,
      content_media_type: nil,
      content_schema: nil
    )
      @definitions = definitions
      @dependencies = dependencies
      @recursive_anchor = recursive_anchor
      @recursive_ref = recursive_ref
      @id = id
      @schema = schema
      @ref = ref
      @anchor = anchor
      @dynamic_ref = dynamic_ref
      @dynamic_anchor = dynamic_anchor
      @vocabulary = vocabulary
      @comment = comment
      @defs = defs
      @prefix_items = prefix_items
      @items = items
      @contains = contains
      @additional_properties = additional_properties
      @properties = properties
      @pattern_properties = pattern_properties
      @dependent_schemas = dependent_schemas
      @property_names = property_names
      @if_ = if_
      @then_ = then_
      @else_ = else_
      @all_of = all_of
      @any_of = any_of
      @one_of = one_of
      @not_ = not_
      @unevaluated_items = unevaluated_items
      @unevaluated_properties = unevaluated_properties
      @type = type
      @const = const
      @enum = enum
      @multiple_of = multiple_of
      @maximum = maximum
      @exclusive_maximum = exclusive_maximum
      @minimum = minimum
      @exclusive_minimum = exclusive_minimum
      @max_length = max_length
      @min_length = min_length
      @pattern = pattern
      @max_items = max_items
      @min_items = min_items
      @unique_items = unique_items
      @max_contains = max_contains
      @min_contains = min_contains
      @max_properties = max_properties
      @min_properties = min_properties
      @required = required
      @dependent_required = dependent_required
      @title = title
      @description = description
      @default = default
      @deprecated = deprecated
      @read_only = read_only
      @write_only = write_only
      @examples = examples
      @format = format
      @content_encoding = content_encoding
      @content_media_type = content_media_type
      @content_schema = content_schema

      @_extra = {}
    end

    attr_accessor :definitions,
                  :dependencies,
                  :recursive_anchor,
                  :recursive_ref,
                  :id,
                  :schema,
                  :ref,
                  :anchor,
                  :dynamic_ref,
                  :dynamic_anchor,
                  :vocabulary,
                  :comment,
                  :defs,
                  :prefix_items,
                  :items,
                  :contains,
                  :additional_properties,
                  :properties,
                  :pattern_properties,
                  :dependent_schemas,
                  :property_names,
                  :if_,
                  :then_,
                  :else_,
                  :all_of,
                  :any_of,
                  :one_of,
                  :not_,
                  :unevaluated_items,
                  :unevaluated_properties,
                  :type,
                  :const,
                  :enum,
                  :multiple_of,
                  :maximum,
                  :exclusive_maximum,
                  :minimum,
                  :exclusive_minimum,
                  :max_length,
                  :min_length,
                  :pattern,
                  :max_items,
                  :min_items,
                  :unique_items,
                  :max_contains,
                  :min_contains,
                  :max_properties,
                  :min_properties,
                  :required,
                  :dependent_required,
                  :title,
                  :description,
                  :default,
                  :deprecated,
                  :read_only,
                  :write_only,
                  :examples,
                  :format,
                  :content_encoding,
                  :content_media_type,
                  :content_schema

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.coerce_definitions(value)
      return value unless value.is_a?(Hash)

      value.transform_values do |entry|
        if entry.is_a?(Schematrix::Meta::Schema)
          entry.to_h
        elsif entry.is_a?(Hash)
          Schematrix::Meta::Schema.from_h(entry)
        else
          entry
        end
      end
    end

    def self.coerce_dependencies(value)
      return value unless value.is_a?(Hash)

      value.transform_values do |entry|
        if entry.is_a?(Schematrix::Meta::Schema)
          entry.to_h
        elsif entry.is_a?(Hash)
          Schematrix::Meta::Schema.from_h(entry)
        else
          entry
        end
      end
    end

    def self.coerce_defs(value)
      return value unless value.is_a?(Hash)

      value.transform_values do |entry|
        if entry.is_a?(Schematrix::Meta::Schema)
          entry.to_h
        elsif entry.is_a?(Hash)
          Schematrix::Meta::Schema.from_h(entry)
        else
          entry
        end
      end
    end

    def self.coerce_prefix_items(value)
      return value unless value.is_a?(Array)

      value.map do |element|
        if element.is_a?(Schematrix::Meta::Schema)
          element.to_h
        elsif element.is_a?(Hash)
          Schematrix::Meta::Schema.from_h(element)
        else
          element
        end
      end
    end

    def self.coerce_items(value)
      if value.is_a?(Schematrix::Meta::Schema)
        value.to_h
      elsif value.is_a?(Hash)
        Schematrix::Meta::Schema.from_h(value)
      else
        value
      end
    end

    def self.coerce_contains(value)
      if value.is_a?(Schematrix::Meta::Schema)
        value.to_h
      elsif value.is_a?(Hash)
        Schematrix::Meta::Schema.from_h(value)
      else
        value
      end
    end

    def self.coerce_additional_properties(value)
      if value.is_a?(Schematrix::Meta::Schema)
        value.to_h
      elsif value.is_a?(Hash)
        Schematrix::Meta::Schema.from_h(value)
      else
        value
      end
    end

    def self.coerce_properties(value)
      return value unless value.is_a?(Hash)

      value.transform_values do |entry|
        if entry.is_a?(Schematrix::Meta::Schema)
          entry.to_h
        elsif entry.is_a?(Hash)
          Schematrix::Meta::Schema.from_h(entry)
        else
          entry
        end
      end
    end

    def self.coerce_pattern_properties(value)
      return value unless value.is_a?(Hash)

      value.transform_values do |entry|
        if entry.is_a?(Schematrix::Meta::Schema)
          entry.to_h
        elsif entry.is_a?(Hash)
          Schematrix::Meta::Schema.from_h(entry)
        else
          entry
        end
      end
    end

    def self.coerce_dependent_schemas(value)
      return value unless value.is_a?(Hash)

      value.transform_values do |entry|
        if entry.is_a?(Schematrix::Meta::Schema)
          entry.to_h
        elsif entry.is_a?(Hash)
          Schematrix::Meta::Schema.from_h(entry)
        else
          entry
        end
      end
    end

    def self.coerce_property_names(value)
      if value.is_a?(Schematrix::Meta::Schema)
        value.to_h
      elsif value.is_a?(Hash)
        Schematrix::Meta::Schema.from_h(value)
      else
        value
      end
    end

    def self.coerce_if_(value)
      if value.is_a?(Schematrix::Meta::Schema)
        value.to_h
      elsif value.is_a?(Hash)
        Schematrix::Meta::Schema.from_h(value)
      else
        value
      end
    end

    def self.coerce_then_(value)
      if value.is_a?(Schematrix::Meta::Schema)
        value.to_h
      elsif value.is_a?(Hash)
        Schematrix::Meta::Schema.from_h(value)
      else
        value
      end
    end

    def self.coerce_else_(value)
      if value.is_a?(Schematrix::Meta::Schema)
        value.to_h
      elsif value.is_a?(Hash)
        Schematrix::Meta::Schema.from_h(value)
      else
        value
      end
    end

    def self.coerce_all_of(value)
      return value unless value.is_a?(Array)

      value.map do |element|
        if element.is_a?(Schematrix::Meta::Schema)
          element.to_h
        elsif element.is_a?(Hash)
          Schematrix::Meta::Schema.from_h(element)
        else
          element
        end
      end
    end

    def self.coerce_any_of(value)
      return value unless value.is_a?(Array)

      value.map do |element|
        if element.is_a?(Schematrix::Meta::Schema)
          element.to_h
        elsif element.is_a?(Hash)
          Schematrix::Meta::Schema.from_h(element)
        else
          element
        end
      end
    end

    def self.coerce_one_of(value)
      return value unless value.is_a?(Array)

      value.map do |element|
        if element.is_a?(Schematrix::Meta::Schema)
          element.to_h
        elsif element.is_a?(Hash)
          Schematrix::Meta::Schema.from_h(element)
        else
          element
        end
      end
    end

    def self.coerce_not_(value)
      if value.is_a?(Schematrix::Meta::Schema)
        value.to_h
      elsif value.is_a?(Hash)
        Schematrix::Meta::Schema.from_h(value)
      else
        value
      end
    end

    def self.coerce_unevaluated_items(value)
      if value.is_a?(Schematrix::Meta::Schema)
        value.to_h
      elsif value.is_a?(Hash)
        Schematrix::Meta::Schema.from_h(value)
      else
        value
      end
    end

    def self.coerce_unevaluated_properties(value)
      if value.is_a?(Schematrix::Meta::Schema)
        value.to_h
      elsif value.is_a?(Hash)
        Schematrix::Meta::Schema.from_h(value)
      else
        value
      end
    end

    def self.coerce_content_schema(value)
      if value.is_a?(Schematrix::Meta::Schema)
        value.to_h
      elsif value.is_a?(Hash)
        Schematrix::Meta::Schema.from_h(value)
      else
        value
      end
    end

    def self.from_h(hash)
      instance =
        new(
          recursive_anchor: hash["$recursiveAnchor"],
          recursive_ref: hash["$recursiveRef"],
          id: hash["$id"],
          schema: hash["$schema"],
          ref: hash["$ref"],
          anchor: hash["$anchor"],
          dynamic_ref: hash["$dynamicRef"],
          dynamic_anchor: hash["$dynamicAnchor"],
          vocabulary: hash["$vocabulary"],
          comment: hash["$comment"],
          defs: coerce_defs(hash["$defs"]),
          prefix_items: coerce_prefix_items(hash["prefixItems"]),
          items: coerce_items(hash["items"]),
          contains: coerce_contains(hash["contains"]),
          additional_properties:
            coerce_additional_properties(hash["additionalProperties"]),
          property_names: coerce_property_names(hash["propertyNames"]),
          if_: coerce_if_(hash["if"]),
          then_: coerce_then_(hash["then"]),
          else_: coerce_else_(hash["else"]),
          all_of: coerce_all_of(hash["allOf"]),
          any_of: coerce_any_of(hash["anyOf"]),
          one_of: coerce_one_of(hash["oneOf"]),
          not_: coerce_not_(hash["not"]),
          unevaluated_items: coerce_unevaluated_items(hash["unevaluatedItems"]),
          unevaluated_properties:
            coerce_unevaluated_properties(hash["unevaluatedProperties"]),
          type: hash["type"],
          const: hash["const"],
          enum: hash["enum"],
          multiple_of: hash["multipleOf"],
          maximum: hash["maximum"],
          exclusive_maximum: hash["exclusiveMaximum"],
          minimum: hash["minimum"],
          exclusive_minimum: hash["exclusiveMinimum"],
          max_length: hash["maxLength"],
          min_length: hash["minLength"],
          pattern: hash["pattern"],
          max_items: hash["maxItems"],
          min_items: hash["minItems"],
          max_contains: hash["maxContains"],
          max_properties: hash["maxProperties"],
          min_properties: hash["minProperties"],
          dependent_required: hash["dependentRequired"],
          title: hash["title"],
          description: hash["description"],
          default: hash["default"],
          examples: hash["examples"],
          format: hash["format"],
          content_encoding: hash["contentEncoding"],
          content_media_type: hash["contentMediaType"],
          content_schema: coerce_content_schema(hash["contentSchema"])
        )
      instance.definitions =
        coerce_definitions(hash["definitions"]) if hash.key?("definitions")
      instance.dependencies =
        coerce_dependencies(hash["dependencies"]) if hash.key?("dependencies")
      instance.properties = coerce_properties(hash["properties"]) if hash.key?(
        "properties"
      )
      instance.pattern_properties =
        coerce_pattern_properties(hash["patternProperties"]) if hash.key?(
        "patternProperties"
      )
      instance.dependent_schemas =
        coerce_dependent_schemas(hash["dependentSchemas"]) if hash.key?(
        "dependentSchemas"
      )
      instance.unique_items = hash["uniqueItems"] if hash.key?("uniqueItems")
      instance.min_contains = hash["minContains"] if hash.key?("minContains")
      instance.required = hash["required"] if hash.key?("required")
      instance.deprecated = hash["deprecated"] if hash.key?("deprecated")
      instance.read_only = hash["readOnly"] if hash.key?("readOnly")
      instance.write_only = hash["writeOnly"] if hash.key?("writeOnly")

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["definitions"] = self.class.coerce_definitions(
        @definitions
      ) unless @definitions.nil?
      result["dependencies"] = self.class.coerce_dependencies(
        @dependencies
      ) unless @dependencies.nil?
      result[
        "$recursiveAnchor"
      ] = @recursive_anchor unless @recursive_anchor.nil?
      result["$recursiveRef"] = @recursive_ref unless @recursive_ref.nil?
      result["$id"] = @id unless @id.nil?
      result["$schema"] = @schema unless @schema.nil?
      result["$ref"] = @ref unless @ref.nil?
      result["$anchor"] = @anchor unless @anchor.nil?
      result["$dynamicRef"] = @dynamic_ref unless @dynamic_ref.nil?
      result["$dynamicAnchor"] = @dynamic_anchor unless @dynamic_anchor.nil?
      result["$vocabulary"] = @vocabulary unless @vocabulary.nil?
      result["$comment"] = @comment unless @comment.nil?
      result["$defs"] = self.class.coerce_defs(@defs) unless @defs.nil?
      result["prefixItems"] = self.class.coerce_prefix_items(
        @prefix_items
      ) unless @prefix_items.nil?
      result["items"] = self.class.coerce_items(@items) unless @items.nil?
      result["contains"] = self.class.coerce_contains(
        @contains
      ) unless @contains.nil?
      result["additionalProperties"] = self.class.coerce_additional_properties(
        @additional_properties
      ) unless @additional_properties.nil?
      result["properties"] = self.class.coerce_properties(
        @properties
      ) unless @properties.nil?
      result["patternProperties"] = self.class.coerce_pattern_properties(
        @pattern_properties
      ) unless @pattern_properties.nil?
      result["dependentSchemas"] = self.class.coerce_dependent_schemas(
        @dependent_schemas
      ) unless @dependent_schemas.nil?
      result["propertyNames"] = self.class.coerce_property_names(
        @property_names
      ) unless @property_names.nil?
      result["if"] = self.class.coerce_if_(@if_) unless @if_.nil?
      result["then"] = self.class.coerce_then_(@then_) unless @then_.nil?
      result["else"] = self.class.coerce_else_(@else_) unless @else_.nil?
      result["allOf"] = self.class.coerce_all_of(@all_of) unless @all_of.nil?
      result["anyOf"] = self.class.coerce_any_of(@any_of) unless @any_of.nil?
      result["oneOf"] = self.class.coerce_one_of(@one_of) unless @one_of.nil?
      result["not"] = self.class.coerce_not_(@not_) unless @not_.nil?
      result["unevaluatedItems"] = self.class.coerce_unevaluated_items(
        @unevaluated_items
      ) unless @unevaluated_items.nil?
      result[
        "unevaluatedProperties"
      ] = self.class.coerce_unevaluated_properties(
        @unevaluated_properties
      ) unless @unevaluated_properties.nil?
      result["type"] = @type unless @type.nil?
      result["const"] = @const unless @const.nil?
      result["enum"] = @enum unless @enum.nil?
      result["multipleOf"] = @multiple_of unless @multiple_of.nil?
      result["maximum"] = @maximum unless @maximum.nil?
      result[
        "exclusiveMaximum"
      ] = @exclusive_maximum unless @exclusive_maximum.nil?
      result["minimum"] = @minimum unless @minimum.nil?
      result[
        "exclusiveMinimum"
      ] = @exclusive_minimum unless @exclusive_minimum.nil?
      result["maxLength"] = @max_length unless @max_length.nil?
      result["minLength"] = @min_length unless @min_length.nil?
      result["pattern"] = @pattern unless @pattern.nil?
      result["maxItems"] = @max_items unless @max_items.nil?
      result["minItems"] = @min_items unless @min_items.nil?
      result["uniqueItems"] = @unique_items unless @unique_items.nil?
      result["maxContains"] = @max_contains unless @max_contains.nil?
      result["minContains"] = @min_contains unless @min_contains.nil?
      result["maxProperties"] = @max_properties unless @max_properties.nil?
      result["minProperties"] = @min_properties unless @min_properties.nil?
      result["required"] = @required unless @required.nil?
      result[
        "dependentRequired"
      ] = @dependent_required unless @dependent_required.nil?
      result["title"] = @title unless @title.nil?
      result["description"] = @description unless @description.nil?
      result["default"] = @default unless @default.nil?
      result["deprecated"] = @deprecated unless @deprecated.nil?
      result["readOnly"] = @read_only unless @read_only.nil?
      result["writeOnly"] = @write_only unless @write_only.nil?
      result["examples"] = @examples unless @examples.nil?
      result["format"] = @format unless @format.nil?
      result[
        "contentEncoding"
      ] = @content_encoding unless @content_encoding.nil?
      result[
        "contentMediaType"
      ] = @content_media_type unless @content_media_type.nil?
      result["contentSchema"] = self.class.coerce_content_schema(
        @content_schema
      ) unless @content_schema.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
