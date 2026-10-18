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
      end
    end
  end
end
