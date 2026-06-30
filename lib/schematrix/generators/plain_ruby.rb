require_relative 'base_generator'

module Schematrix
  module Generators
    # Outputs a schema as a plain, mutable Ruby class
    class PlainRuby < BaseGenerator
      def self.template_name
        'plain_ruby.erb'
      end

      def self.file_extension
        '.rb'
      end

      private

      def plain_attr_accessor_list
        @properties.keys.map(&:to_sym).map(&:inspect).join(', ')
      end
    end
  end
end
