require_relative 'base'
require_relative 'ruby_helpers'
require_relative 'sorbet_helpers'

module Schematrix
  module Generators
    module Templates
      # RBI template class
      class Rbi < Base
        include RubyHelpers
        include SorbetHelpers

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
end
