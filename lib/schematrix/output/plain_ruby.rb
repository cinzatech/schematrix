require_relative 'base_generator'

module Schematrix
  module Output
    # Outputs a schema as a plain, mutable Ruby class
    class PlainRuby < BaseGenerator
      private

      def file_extension
        '.rb'
      end

      def template_name
        'plain_ruby.erb'
      end

      def plain_attr_accessor_list(properties)
        properties.keys.map(&:to_sym).map(&:inspect).join(', ')
      end
    end
  end
end
