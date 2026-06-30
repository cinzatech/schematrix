require_relative 'base'
require_relative 'ruby_helpers'
require_relative 'sorbet_helpers'

module Schematrix
  module Generators
    module Templates
      # Sorbet Ruby template class
      class SorbetRuby < Base
        include RubyHelpers
        include SorbetHelpers

        private

        def sorbet_attr_accessor(path, name, property)
          <<~RUBY
            sig { returns(
              #{sorbet_type(path, name, property)}
            ) }
            attr_accessor :#{name}
          RUBY
        end
      end
    end
  end
end
