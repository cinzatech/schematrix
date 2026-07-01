module Schematrix
  module Generators
    module Templates
      # Common functions for Ruby class name and file handling
      module RubyHelpers
        def constructor_arguments
          return '' if @properties.nil?

          @properties.map do |name, schema|
            next "#{name}: #{schema.default.inspect}" unless schema.default.nil?
            next "#{name}: #{nil.inspect}" unless schema.required

            "#{name}:"
          end.join(', ')
        end

        def constructor_assignments
          return '' if @properties.nil?

          @properties.map do |name, _schema|
            "@#{name} = #{name}"
          end.join("\n")
        end
      end
    end
  end
end
