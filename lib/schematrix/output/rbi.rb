require_relative 'base_generator'
require_relative 'sorbet_helpers'

module Schematrix
  module Output
    # Outputs a schema as an RBI sorbet signature file
    class Rbi < BaseGenerator
      include SorbetHelpers

      private

      def template_name
        'rbi.erb'
      end

      def file_extension
        '.rbi'
      end

      def sorbet_attr_accessor(path, name, property)
        type = sorbet_type(path, name, property)
        <<~RUBY
          sig { returns(#{type}) }
          def #{name}; end

          sig { params(#{name}: #{type}).void }
          def #{name}=(#{name}); end
        RUBY
      end
    end
  end
end
