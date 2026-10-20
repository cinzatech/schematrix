require_relative "base"
require_relative "ruby_helpers"
require_relative "sorbet_helpers"

module Schematrix
  module Generators
    module Templates
      # Rendering logic for the Sorbet Ruby generator
      class SorbetRuby < Base
        include RubyHelpers
        include SorbetHelpers

        private

        def sorbet_attr_accessor(path, name, property)
          <<~RUBY
            sig { returns(
              #{property_type_of(path, name, property)}
            ) }
            attr_accessor :#{name}
          RUBY
        end
      end
    end
  end
end
