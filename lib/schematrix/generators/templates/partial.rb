require_relative "base"
require_relative "plain_ruby"
require_relative "rbi"
require_relative "rbs"
require_relative "sorbet_ruby"

module Schematrix
  module Generators
    module Templates
      # Rendering logic for the four partial generators. Every slot
      # wraps in the Maybe type, required ones included, so a partial
      # class records which keys its document carried; the flag the
      # generators pass flips the all-slots rule the shared
      # RubyHelpers and type algebra read. The method bodies and
      # signatures come from the data-format template classes the
      # subclasses reuse.
      class PartialPlainRuby < PlainRuby
      end

      class PartialSorbetRuby < SorbetRuby
      end

      class PartialRbi < Rbi
      end

      class PartialRbs < Rbs
      end
    end
  end
end
