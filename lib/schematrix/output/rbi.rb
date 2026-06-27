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
    end
  end
end
