require_relative "generators/base"
require_relative "generators/coercion_helper"

module Schematrix
  module Generators
    # The generator registry the CLI resolves `-g` names against:
    # `plain_ruby`, `rbs`, `sorbet_ruby`, `rbi`, and the dsl_ prefixed
    # builders of each, plus the run-once `coercion_helper` auxiliary
    # generator.
    GENERATORS = {
      "plain_ruby" => Generators::PlainRuby,
      "rbs" => Generators::Rbs,
      "sorbet_ruby" => Generators::SorbetRuby,
      "rbi" => Generators::Rbi,
      "dsl_plain_ruby" => Generators::DslPlainRuby,
      "dsl_sorbet_ruby" => Generators::DslSorbetRuby,
      "dsl_rbi" => Generators::DslRbi,
      "dsl_rbs" => Generators::DslRbs,
      "coercion_helper" => Generators::CoercionHelper,
    }.freeze
  end
end
