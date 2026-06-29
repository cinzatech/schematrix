require_relative 'base_generator'
require_relative 'sorbet_helpers'

module Schematrix
  module Output
    # Outputs a schema as a mutable Ruby class with inline Sorbet signatures
    class SorbetRuby < BaseGenerator
      include SorbetHelpers

      private

      def file_extension
        '.rb'
      end

      def template_name
        'sorbet_ruby.erb'
      end

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
