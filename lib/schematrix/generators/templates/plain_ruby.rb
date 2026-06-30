require_relative 'base'
require_relative 'ruby_helpers'

module Schematrix
  module Generators
    module Templates
      # Plain Ruby template class
      class PlainRuby < Base
        include RubyHelpers

        private

        def plain_attr_accessor_list
          @properties.keys.map(&:to_sym).map(&:inspect).join(', ')
        end
      end
    end
  end
end
