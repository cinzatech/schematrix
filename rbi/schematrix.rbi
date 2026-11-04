# typed: strict

# The Sorbet signatures of the schematrix library API, as documented in
# docs/library-api.md. Tapioca merges this file into the gem's RBI, so
# every method here must match the loaded code; test/test_rbi.rb checks
# that.
module Schematrix
  VERSION = T.let(T.unsafe(nil), String)

  # The CLI resolves `-g` names against this registry.
  GENERATORS =
    T.let(
      T.unsafe(nil),
      T::Hash[String, T.class_of(Schematrix::Generators::Base)],
    )

  # The rendering of every JSON Schema scalar type and standard format,
  # keyed by [type, format].
  BUILTIN_SCALAR_TYPES =
    T.let(
      T.unsafe(nil),
      T::Hash[[String, T.nilable(String)], Schematrix::ScalarType],
    )

  # The cumulative compilation work limit the pipeline enforces.
  class CompilationBudget
    DEFAULT_LIMIT = T.let(T.unsafe(nil), Integer)
  end

  class << self
    # The pipeline logs through this object when one is set; nil keeps a
    # library run silent. Anything answering debug, info, warn and fatal
    # works, the CLI assigns a TTY::Logger.
    sig { returns(T.untyped) }
    def logger
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def logger=(value)
    end

    # Compiles every schema reachable from the input files and writes one
    # file per compiled object schema per generator, plus each run-once
    # generator's auxiliary files. Returns the compiled records keyed by
    # schema locator.
    sig do
      params(
        generators: T::Array[Schematrix::Generators::Base],
        input_files: T::Array[String],
        closed_shapes: T::Boolean,
        schema_dirs: T::Array[String],
        max_compilation_work: Integer,
      ).returns(T::Hash[String, Schematrix::Schema])
    end
    def generate(
      generators:,
      input_files:,
      closed_shapes: false,
      schema_dirs: [],
      max_compilation_work: CompilationBudget::DEFAULT_LIMIT
    )
    end
  end

  # A compiled schema record. The library API treats it as opaque.
  class Schema < ::Data
  end

  # How a [type, format] pair renders in each notation, and the module
  # that converts its values on load and dump.
  class ScalarType < ::Data
    sig do
      params(
        sorbet: String,
        rbs: String,
        coercer: T.nilable(T::Module[T.anything]),
        reader: T.nilable(T::Module[T.anything]),
      ).void
    end
    def initialize(sorbet:, rbs:, coercer: nil, reader: nil)
    end

    sig { returns(String) }
    def sorbet
    end

    sig { returns(String) }
    def rbs
    end

    sig { returns(T.nilable(T::Module[T.anything])) }
    def coercer
    end

    sig { returns(T.nilable(T::Module[T.anything])) }
    def reader
    end

    sig { returns(T::Boolean) }
    def coerces?
    end
  end

  class OutputCollisionError < StandardError
  end

  class CoercionHelperCollisionError < StandardError
  end

  class CoercionConflictError < StandardError
  end

  class UnresolvableLocatorError < StandardError
  end

  class InvalidSchemaError < StandardError
  end

  class UnsupportedDialectError < StandardError
  end

  # The value converters the standard formats ship with.
  module Coercers
    BUILTIN = T.let(T.unsafe(nil), T::Array[T::Module[T.anything]])

    module Date
      GENERATED_REQUIRE = T.let(T.unsafe(nil), String)
      GENERATED_BODY = T.let(T.unsafe(nil), String)

      sig { params(value: T.untyped).returns(T.untyped) }
      def self.coerce(value)
      end
    end

    module DateTime
      GENERATED_REQUIRE = T.let(T.unsafe(nil), String)
      GENERATED_BODY = T.let(T.unsafe(nil), String)

      sig { params(value: T.untyped).returns(T.untyped) }
      def self.coerce(value)
      end
    end
  end

  module Generators
    # Base class of every output generator. A generator renders one
    # file per compiled class into its output directory, under its
    # module name.
    class Base
      sig do
        params(
          output_dir: String,
          module_name: String,
          format: T::Boolean,
          command: T.nilable(String),
          scalar_types:
            T::Hash[[String, T.nilable(String)], Schematrix::ScalarType],
          immutable: T::Boolean,
          optionals: Symbol,
          maybe: T.nilable(T::Module[T.anything]),
          enums: T.nilable(Symbol),
        ).void
      end
      def initialize(
        output_dir,
        module_name,
        format: true,
        command: nil,
        scalar_types: {},
        immutable: false,
        optionals: :nilable,
        maybe: nil,
        enums: nil
      )
      end

      sig { returns(String) }
      def output_dir
      end

      sig { returns(String) }
      def module_name
      end

      sig { returns(T::Boolean) }
      def format
      end

      sig { returns(T.nilable(String)) }
      def command
      end

      sig { returns(T.nilable(Symbol)) }
      def enums
      end

      sig { returns(T::Boolean) }
      def self.enum_generator?
      end

      sig { returns(T::Boolean) }
      def self.immutable_supported?
      end

      sig { returns(T::Boolean) }
      def self.run_once?
      end

      sig { returns(T::Boolean) }
      def self.partial?
      end

      sig { returns(Symbol) }
      def self.maybe_flavor
      end

      sig { returns(T::Boolean) }
      def self.maybe_supported?
      end

      sig { returns(String) }
      def self.file_extension
      end

      # The file this locator's class writes to, without writing it.
      sig { params(locator: String).returns(String) }
      def target_path(locator)
      end

      sig { params(locator: String, object: Schematrix::Schema).void }
      def validate_enum_members(locator, object)
      end

      # Renders, formats and writes the file for this locator's class.
      # Returns the path written.
      sig do
        params(
          locator: String,
          object: Schematrix::Schema,
          enums: Symbol,
        ).returns(String)
      end
      def write(locator, object, enums: T.unsafe(nil))
      end

      # Fills the template for one class and formats the result. Returns
      # the file content.
      sig do
        params(
          path: T.any(String, URI::Generic),
          class_name: String,
          object: Schematrix::Schema,
          enums: Symbol,
        ).returns(String)
      end
      def transform(path, class_name, object, enums: T.unsafe(nil))
      end

      sig { returns(T::Boolean) }
      def maybe_needed?
      end
    end

    class PlainRuby < Base
    end

    class SorbetRuby < Base
    end

    class Rbi < Base
    end

    class Rbs < Base
    end

    class PlainRubyEnums < PlainRuby
    end

    class SorbetRubyEnums < SorbetRuby
    end

    class RbiEnums < Rbi
    end

    class RbsEnums < Rbs
    end

    class DslPlainRuby < Base
    end

    class DslSorbetRuby < Base
    end

    class DslRbi < Base
    end

    class DslRbs < Base
    end

    class DslParser < Base
    end

    class PartialPlainRuby < Base
    end

    class PartialSorbetRuby < Base
    end

    class PartialRbi < Base
    end

    class PartialRbs < Base
    end

    # Writes the shared coercion helper module once per run.
    class AuxiliaryFiles < Base
      sig { returns(T::Array[String]) }
      def run_once_target_paths
      end

      sig do
        params(_objects: T::Hash[String, Schematrix::Schema]).returns(String)
      end
      def write_run_once(_objects)
      end

      sig { returns(T::Hash[String, String]) }
      def run_once_render
      end
    end

    # Writes the generated Maybe module once per output directory.
    class Maybe < AuxiliaryFiles
      sig do
        params(
          output_dir: String,
          module_name: String,
          flavor: Symbol,
          format: T::Boolean,
          command: T.nilable(String),
        ).void
      end
      def initialize(output_dir, module_name, flavor:, format:, command: nil)
      end
    end
  end
end
