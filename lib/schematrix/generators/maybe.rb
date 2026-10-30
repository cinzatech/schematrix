require_relative "auxiliary_files"

module Schematrix
  module Generators
    # Writes the generated Maybe module once per output directory,
    # for every generator the pipeline runs with optionals: :maybe
    # and no supplied maybe module. The flavor follows the generator
    # family: the Sorbet formats get the sealed generic under
    # `# typed: strict`, the plain formats the same classes without
    # the signatures, and the RBS formats the signatures alone. Like
    # the coercion helper, the file lands next to the class files
    # that reference it, and the generated code depends on nothing
    # but sorbet-runtime in the Sorbet formats.
    class Maybe < AuxiliaryFiles
      def initialize(output_dir, module_name, flavor:, format:, command: nil)
        super(output_dir, module_name, format:, command:)
        @flavor = flavor
      end

      # The static targets the flavor claims, so a schema class
      # folding onto one of them fails the run before any file is
      # written.
      def run_once_target_paths
        [File.join(@output_dir, "maybe#{extension}")]
      end

      def write_run_once(_objects)
        FileUtils.mkdir_p(@output_dir)
        run_once_render.each do |filename, code|
          File.write(File.join(@output_dir, filename), code)
        end
        run_once_target_paths.first
      end

      def run_once_render
        { "maybe#{extension}" => rendered_code }
      end

      private

      # The extension the flavor writes: Ruby code for the two
      # executable renderings, signatures alone for the two
      # signature notations.
      def extension
        { sorbet: ".rb", plain: ".rb", rbs: ".rbs", rbi: ".rbi" }.fetch(@flavor)
      end

      def rendered_code
        case @flavor
        when :sorbet
          with_banner(format_code(sorbet_code), "Maybe", "module")
        when :plain
          with_banner(format_code(plain_code), "Maybe", "module")
        when :rbs
          with_banner(rbs_format(rbs_code), "Maybe", "module")
        when :rbi
          with_banner(format_code(rbi_code), "Maybe", "module")
        end
      end

      def rbs_format(code)
        @format ? SyntaxTree::RBS.format(code) : code
      end

      # The signatures alone, for the rbi generators: same surface as
      # the executable Sorbet rendering, empty bodies.
      def rbi_code
        <<~RUBY
          # typed: strict

          module #{@module_name}
            module Maybe
              extend T::Sig
              extend T::Generic
              extend T::Helpers

              interface!
              sealed!

              Value = type_member(:out)

              sig { type_parameters(:V).params(value: T.type_parameter(:V)).returns(Maybe[T.type_parameter(:V)]) }
              def self.from(value); end

              sig { returns(Absent) }
              def self.empty; end

              sig { abstract.returns(T::Boolean) }
              def present?; end

              sig { abstract.returns(T::Boolean) }
              def absent?; end

              sig { abstract.type_parameters(:D).params(default: T.type_parameter(:D)).returns(T.any(Value, T.type_parameter(:D))) }
              def or_default(default); end

              sig { abstract.type_parameters(:R).params(block: T.proc.params(value: Value).returns(T.type_parameter(:R))).returns(T.nilable(T.type_parameter(:R))) }
              def when_present(&block); end

              sig { abstract.type_parameters(:R).params(block: T.proc.params(value: Value).returns(T.type_parameter(:R))).returns(Maybe[T.type_parameter(:R)]) }
              def map(&block); end

              class Present
                extend T::Sig
                extend T::Generic
                extend T::Helpers
                include Maybe

                final!

                Value = type_member(:out)

                sig(:final) { params(value: Value).void }
                def initialize(value); end

                sig(:final) { returns(Value) }
                attr_reader :value

                sig(:final) { override.returns(TrueClass) }
                def present?; end

                sig(:final) { override.returns(FalseClass) }
                def absent?; end

                sig(:final) { override.type_parameters(:D).params(default: T.type_parameter(:D)).returns(T.any(Value, T.type_parameter(:D))) }
                def or_default(default); end

                sig(:final) { override.type_parameters(:R).params(block: T.proc.params(value: Value).returns(T.type_parameter(:R))).returns(T.nilable(T.type_parameter(:R))) }
                def when_present(&block); end

                sig(:final) { override.type_parameters(:R).params(block: T.proc.params(value: Value).returns(T.type_parameter(:R))).returns(Maybe[T.type_parameter(:R)]) }
                def map(&block); end

                sig(:final) { params(other: T.untyped).returns(T::Boolean) }
                def ==(other); end

                sig(:final) { returns(Integer) }
                def hash; end
              end

              class Absent
                extend T::Sig
                extend T::Generic
                extend T::Helpers
                include Maybe

                final!

                Value = type_member(:out) { { fixed: T.noreturn } }

                sig(:final) { override.returns(FalseClass) }
                def present?; end

                sig(:final) { override.returns(TrueClass) }
                def absent?; end

                sig(:final) { override.type_parameters(:D).params(default: T.type_parameter(:D)).returns(T.type_parameter(:D)) }
                def or_default(default); end

                sig(:final) { override.type_parameters(:R).params(block: T.proc.params(value: Value).returns(T.type_parameter(:R))).returns(T.nilable(T.type_parameter(:R))) }
                def when_present(&block); end

                sig(:final) { override.type_parameters(:R).params(block: T.proc.params(value: Value).returns(T.type_parameter(:R))).returns(Maybe[T.type_parameter(:R)]) }
                def map(&block); end

                sig(:final) { params(other: T.untyped).returns(T::Boolean) }
                def ==(other); end

                sig(:final) { returns(Integer) }
                def hash; end

                INSTANCE = T.let(new.freeze, Absent)
              end
            end
          end
        RUBY
      end

      def sorbet_code
        <<~RUBY
          # typed: strict

          module #{@module_name}
            # A value that may be absent. Absent means the document had no key;
            # Present(nil) means the key was there with a null.
            module Maybe
              extend T::Sig
              extend T::Generic
              extend T::Helpers

              interface!
              sealed!

              Value = type_member(:out)

              sig { type_parameters(:V).params(value: T.type_parameter(:V)).returns(Maybe[T.type_parameter(:V)]) }
              def self.from(value)
                Present[T.type_parameter(:V)].new(value)
              end

              sig { returns(Absent) }
              def self.empty
                Absent::INSTANCE
              end

              sig { abstract.returns(T::Boolean) }
              def present?; end

              sig { abstract.returns(T::Boolean) }
              def absent?; end

              sig { abstract.type_parameters(:D).params(default: T.type_parameter(:D)).returns(T.any(Value, T.type_parameter(:D))) }
              def or_default(default); end

              sig { abstract.type_parameters(:R).params(block: T.proc.params(value: Value).returns(T.type_parameter(:R))).returns(T.nilable(T.type_parameter(:R))) }
              def when_present(&block); end

              sig { abstract.type_parameters(:R).params(block: T.proc.params(value: Value).returns(T.type_parameter(:R))).returns(Maybe[T.type_parameter(:R)]) }
              def map(&block); end

              class Present
                extend T::Sig
                extend T::Generic
                extend T::Helpers
                include Maybe

                final!

                Value = type_member(:out)

                sig(:final) { params(value: Value).void }
                def initialize(value)
                  @value = value
                  freeze
                end

                sig(:final) { returns(Value) }
                attr_reader :value

                sig(:final) { override.returns(TrueClass) }
                def present? = true

                sig(:final) { override.returns(FalseClass) }
                def absent? = false

                sig(:final) { override.type_parameters(:D).params(default: T.type_parameter(:D)).returns(T.any(Value, T.type_parameter(:D))) }
                def or_default(default) = @value

                sig(:final) { override.type_parameters(:R).params(block: T.proc.params(value: Value).returns(T.type_parameter(:R))).returns(T.nilable(T.type_parameter(:R))) }
                def when_present(&block) = yield(@value)

                sig(:final) { override.type_parameters(:R).params(block: T.proc.params(value: Value).returns(T.type_parameter(:R))).returns(Maybe[T.type_parameter(:R)]) }
                def map(&block) = Present[T.type_parameter(:R)].new(yield(@value))

                sig(:final) { params(other: T.untyped).returns(T::Boolean) }
                def ==(other) = other.is_a?(Present) && T.unsafe(other.value) == @value

                sig(:final) { params(other: T.untyped).returns(T::Boolean) }
                def eql?(other) = self.==(other)

                sig(:final) { returns(Integer) }
                def hash = [Present, @value].hash
              end

              class Absent
                extend T::Sig
                extend T::Generic
                extend T::Helpers
                include Maybe

                final!

                Value = type_member(:out) { { fixed: T.noreturn } }

                sig(:final) { override.returns(FalseClass) }
                def present? = false

                sig(:final) { override.returns(TrueClass) }
                def absent? = true

                sig(:final) { override.type_parameters(:D).params(default: T.type_parameter(:D)).returns(T.type_parameter(:D)) }
                def or_default(default) = default

                sig(:final) { override.type_parameters(:R).params(block: T.proc.params(value: Value).returns(T.type_parameter(:R))).returns(T.nilable(T.type_parameter(:R))) }
                def when_present(&block) = nil

                sig(:final) { override.type_parameters(:R).params(block: T.proc.params(value: Value).returns(T.type_parameter(:R))).returns(Maybe[T.type_parameter(:R)]) }
                def map(&block) = self

                sig(:final) { params(other: T.untyped).returns(T::Boolean) }
                def ==(other) = other.is_a?(Absent)

                sig(:final) { params(other: T.untyped).returns(T::Boolean) }
                def eql?(other) = self.==(other)

                sig(:final) { returns(Integer) }
                def hash = Absent.hash

                INSTANCE = T.let(new.freeze, Absent)
              end
            end
          end
        RUBY
      end

      def plain_code
        <<~RUBY
          module #{@module_name}
            # A value that may be absent. Absent means the document had no key;
            # Present(nil) means the key was there with a null.
            module Maybe
              def self.from(value)
                Present.new(value)
              end

              def self.empty
                Absent::INSTANCE
              end

              class Present
                include Maybe

                def initialize(value)
                  @value = value
                  freeze
                end

                attr_reader :value

                def present? = true

                def absent? = false

                def or_default(default) = @value

                def when_present(&block) = yield(@value)

                def map(&block) = Present.new(yield(@value))

                def ==(other)
                  other.is_a?(Present) && other.value == @value
                end

                def eql?(other) = self.==(other)

                def hash
                  [Present, @value].hash
                end
              end

              class Absent
                include Maybe

                def present? = false

                def absent? = true

                def or_default(default) = default

                def when_present(&block) = nil

                def map(&block) = self

                def ==(other)
                  other.is_a?(Absent)
                end

                def eql?(other) = self.==(other)

                def hash
                  Absent.hash
                end

                INSTANCE = new.freeze
              end
            end
          end
        RUBY
      end

      def rbs_code
        <<~RBS
          module #{@module_name}
            module Maybe[out V]
              def self.from: [T] (T value) -> Maybe[T]

              def self.empty: -> Maybe[bottom]

              def present?: () -> bool

              def absent?: () -> bool

              def or_default: [D] (D default) -> (V | D)

              def when_present: [R] { (V value) -> R } -> R?

              def map: [R] { (V value) -> R } -> Maybe[R]
            end
          end
        RBS
      end
    end
  end
end
