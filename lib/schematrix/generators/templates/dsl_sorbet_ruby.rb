require_relative "dsl_base"
require_relative "dsl_sorbet_sigs"

module Schematrix
  module Generators
    module Templates
      # Rendering logic for the Sorbet Ruby DSL generator
      class DslSorbetRuby < DslBase
        include DslSorbetSigs
      end
    end
  end
end
