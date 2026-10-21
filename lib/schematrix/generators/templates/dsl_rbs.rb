require_relative "dsl_base"
require_relative "dsl_rbs_notation"

module Schematrix
  module Generators
    module Templates
      # Rendering logic for the RBS DSL generator
      class DslRbs < DslBase
        include DslRbsNotation
      end
    end
  end
end
