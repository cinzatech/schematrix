require_relative 'base_generator'
require_relative 'sorbet_helpers'

module Schematrix
  module Generators
    # Outputs a schema as an RBI sorbet signature file
    class Rbi < BaseGenerator
      include SorbetHelpers

      def self.template_name
        'rbi.erb'
      end

      def self.file_extension
        '.rbi'
      end

      private

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
