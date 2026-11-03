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
        # One declaration for every property when none carries a
        # description; one per property, each under its comment, as
        # soon as one does.
        def plain_attr_accessor_line
          return "" if @properties.nil? || @properties.empty?

          keyword = immutable? ? "attr_reader" : "attr_accessor"
          if @properties.values.none? { |property| property&.description }
            names = @properties.keys.map { |key| key.to_sym.inspect }.join(", ")
            return "#{keyword} #{names}"
          end

          entries =
            @properties.map do |name, property|
              code = "#{keyword} #{name.to_sym.inspect}"
              commented = !property_comment(property).empty?
              [with_property_comment(property, code), commented]
            end
          join_commented(entries)
        end
      end
    end
  end
end
