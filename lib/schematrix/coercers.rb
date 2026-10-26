require "date"
require "time"

module Schematrix
  # The value converters the standard formats ship with. A coercer is
  # any module answering `coerce(value)`: a document value loads, an
  # instance dumps, anything else passes through. Generated output
  # emits its own copy of a built-in coercer next to the coercion
  # helpers (see Generators::Templates::Coercions), so generated code
  # keeps its property of having no runtime dependency on this gem;
  # GENERATED_BODY and GENERATED_REQUIRE are what it emits.
  module Coercers
    # Loads an ISO 8601 full-date string, dumps back to ISO 8601.
    module Date
      GENERATED_REQUIRE = "date"
      GENERATED_BODY = <<~RUBY
        def self.coerce(value)
          case value
          when String then ::Date.iso8601(value)
          when ::Date then value.iso8601
          else value
          end
        end
      RUBY

      # One body serves both sides: the gem's own method and the copy
      # generated output emits can never drift apart.
      module_eval(GENERATED_BODY, __FILE__, __LINE__ + 2)
    end

    # Loads an ISO 8601 date-time string, dumps back to ISO 8601.
    module DateTime
      GENERATED_REQUIRE = "time"
      GENERATED_BODY = <<~RUBY
        def self.coerce(value)
          case value
          when String then ::Time.iso8601(value)
          when ::Time then value.iso8601
          else value
          end
        end
      RUBY

      module_eval(GENERATED_BODY, __FILE__, __LINE__ + 2)
    end

    # The coercers generated output knows how to emit. A coercer a
    # project passes through `scalar_types:` outside this list is
    # referenced by name only, never emitted.
    BUILTIN = [Date, DateTime].freeze
  end
end
