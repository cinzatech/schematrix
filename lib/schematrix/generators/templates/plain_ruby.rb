require_relative "base"
require_relative "ruby_helpers"

module Schematrix
  module Generators
    module Templates
      # Plain Ruby template class
      class PlainRuby < Base
        include RubyHelpers

        private

        # The whole attr_accessor line, or nothing when the schema
        # declares no properties: bare attr_accessor is a load-time
        # ArgumentError.
        def plain_attr_accessor_line
          return "" if @properties.nil? || @properties.empty?

          names = @properties.keys.map { |key| key.to_sym.inspect }.join(", ")
          "attr_accessor #{names}"
        end
      end
    end
  end
end
