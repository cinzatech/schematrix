require_relative "enum_base"

module Schematrix
  module Generators
    module Templates
      # Only the leaf declaration inherits T::Enum, not its enclosing classes.
      class SorbetRubyEnums < EnumBase
        def initialize(members:, class_name:, **)
          collision =
            members.find { |name, _value| name == class_name.split("::").last }
          if collision
            raise OutputCollisionError,
                  "Enum value #{collision.last.inspect} folds onto " \
                    "#{class_name}; Sorbet cannot type a member with " \
                    "its enclosing class's name"
          end
          super
        end

        private

        def declaration_open
          "#{super} < ::T::Enum"
        end
      end
    end
  end
end
