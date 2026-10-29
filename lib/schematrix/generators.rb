require_relative "generators/base"
require_relative "generators/auxiliary_files"
require_relative "generators/maybe"

module Schematrix
  # The generator registry the CLI resolves `-g` names against:
  # `plain_ruby`, `rbs`, `sorbet_ruby`, `rbi`, the dsl_ prefixed
  # builders of each, the partial_ prefixed partial classes of each,
  # plus `auxiliary_files`, the run-once generator for auxiliary
  # files. The generated Maybe module is not a registry entry: the
  # pipeline writes it once per output directory when a generator
  # runs with optionals: :maybe and no supplied maybe module.
  GENERATORS = {
    "plain_ruby" => Generators::PlainRuby,
    "rbs" => Generators::Rbs,
    "sorbet_ruby" => Generators::SorbetRuby,
    "rbi" => Generators::Rbi,
    "dsl_plain_ruby" => Generators::DslPlainRuby,
    "dsl_sorbet_ruby" => Generators::DslSorbetRuby,
    "dsl_rbi" => Generators::DslRbi,
    "dsl_rbs" => Generators::DslRbs,
    "partial_plain_ruby" => Generators::PartialPlainRuby,
    "partial_sorbet_ruby" => Generators::PartialSorbetRuby,
    "partial_rbi" => Generators::PartialRbi,
    "partial_rbs" => Generators::PartialRbs,
    "auxiliary_files" => Generators::AuxiliaryFiles,
  }.freeze
end
