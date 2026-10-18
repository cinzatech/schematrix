module Schematrix
  module Generators
    module Templates
      # Common functions for Ruby class name and file handling
      module RubyHelpers
        def constructor_arguments
          return "" if @properties.nil? || @properties.empty?

          args =
            @properties
              .map do |name, schema|
                unless schema.default.nil?
                  next "#{name}: #{schema.default.inspect}"
                end
                next "#{name}: #{nil.inspect}" unless schema.required

                "#{name}:"
              end
              .join(", ")

          "(#{args})"
        end

        def constructor_assignments
          return "" if @properties.nil?

          @properties.map { |name, _schema| "@#{name} = #{name}" }.join("\n")
        end
      end
    end
  end
end
