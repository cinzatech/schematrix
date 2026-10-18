require_relative "base"
require_relative "ruby_helpers"

module Schematrix
  module Generators
    module Templates
      # Plain Ruby template class
      class PlainRuby < Base
        include RubyHelpers

        private

        def plain_attr_accessor_list
          return "" if @properties.nil?

          @properties.keys.map { |key| key.to_sym.inspect }.join(", ")
        end
      end
    end
  end
end
