require_relative "base"
require_relative "ruby_helpers"

module Schematrix
  module Generators
    module Templates
      # Rendering logic for the plain Ruby generator
      class PlainRuby < Base
        include RubyHelpers

        private

        # The whole accessor line, or nothing when the schema
        # declares no properties: bare attr_accessor is a load-time
        # ArgumentError. Immutable classes carry readers only.
        def plain_attr_accessor_line
          return "" if @properties.nil? || @properties.empty?

          keyword = immutable? ? "attr_reader" : "attr_accessor"
          names = @properties.keys.map { |key| key.to_sym.inspect }.join(", ")
          "#{keyword} #{names}"
        end
      end
    end
  end
end
