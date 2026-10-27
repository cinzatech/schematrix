require_relative "base"
require_relative "ruby_helpers"
require_relative "sorbet_helpers"

module Schematrix
  module Generators
    module Templates
      # Rendering logic for the RBI generator
      class Rbi < Base
        include RubyHelpers
        include SorbetHelpers

        private

        def sorbet_attr_accessor(path, name, property)
          type = property_type_of(path, name, property)
          reader = <<~RUBY
            sig { returns(#{type}) }
            def #{name}; end
          RUBY
          return reader if immutable?

          <<~RUBY
            sig { returns(#{type}) }
            def #{name}; end

            sig { params(#{name}: #{type}).void }
            def #{name}=(#{name}); end
          RUBY
        end

        # The copier's RBI defaults: stub files carry no bodies, so
        # the ivar defaults of the real method spell as T.untyped and
        # the sig carries the contract.
        def rbi_with_parameters
          parameters = property_names.map { |name| "#{name}: T.untyped" }
          parameters << "_extra: T.untyped" unless @additional_properties.nil?
          parameters.join(", ")
        end
      end
    end
  end
end
