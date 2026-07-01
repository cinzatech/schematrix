module Schematrix
  module Generators
    module Templates
      # Abstract base class for templates
      class Base
        include Resolver

        def initialize(
          module_name:,
          path:,
          class_name:,
          properties:,
          additional_properties:,
          documentation_comment:
        )
          @module_name = module_name
          @path = path
          @class_name = class_name
          @properties = properties
          @additional_properties = additional_properties
          @documentation_comment = documentation_comment
        end

        def render(erb)
          erb.result(binding)
        end

        def strictly_required?(schema)
          return false if schema.nil?
          return false if schema.type.nil?
          return false if schema.type.include?('null')
          return false unless schema.required
          return false unless schema.default.nil?

          true
        end
      end
    end
  end
end
