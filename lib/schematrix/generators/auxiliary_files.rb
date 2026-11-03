module Schematrix
  module Generators
    # Writes the shared coercion helper module once per output
    # directory: the built-in coercers under Coercers, the
    # coerce_class_slot dispatcher and the coerce_spec interpreter
    # that generated classes call through qualified names.
    # A run-once generator: the pipeline hands it the whole compiled
    # record set instead of one locator at a time, and the files land
    # next to the class files that require_relative them.
    class AuxiliaryFiles < Base
      def self.run_once? = true

      def self.immutable_supported? = false

      def self.file_extension = ".rb"

      # The static targets the generator claims up front, so a schema
      # class folding onto one of them fails the run before any file
      # is written.
      def run_once_target_paths
        [
          File.join(@output_dir, "coercion_helper.rb"),
          File.join(@output_dir, "coercion_helper.rbs"),
        ]
      end

      # Renders and writes the helper files. The content is the same
      # for every run: the helpers carry no per-class state, the spec
      # literal travels with each delegation, and every built-in
      # coercer is emitted whether or not a class in the run calls it.
      def write_run_once(_objects)
        FileUtils.mkdir_p(@output_dir)
        run_once_render.each do |filename, code|
          File.write(File.join(@output_dir, filename), code)
        end
        run_once_target_paths.first
      end

      # The rendered, formatted helper files, for callers that want
      # the content without writing it.
      def run_once_render
        {
          "coercion_helper.rb" =>
            with_banner(format_code(ruby_code), "CoercionHelper", "module"),
          "coercion_helper.rbs" =>
            with_banner(rbs_code, "CoercionHelper", "module"),
        }
      end

      private

      def ruby_code
        <<~RUBY
          #{builtin_requires}

          module #{@module_name}
            module CoercionHelper
          #{indent(coercers_ruby, 2)}

              def self.coerce_class_slot(value, klass)
                if value.is_a?(klass)
                  value.to_h
                elsif value.is_a?(Hash)
                  klass.from_h(value)
                else
                  value
                end
              end

              def self.coerce_spec(value, spec)
                coercion_result(value, spec).last
              end

              def self.coercion_result(value, spec)
                case spec[0]
                when :coerce, :class
                  converted =
                    if spec[0] == :coerce
                      spec[1].coerce(value)
                    else
                      coerce_class_slot(value, spec[1])
                    end
                  [value.nil? || !converted.equal?(value), converted]
                when :array
                  return [false, value] unless value.is_a?(Array)

                  results =
                    if spec[1][0] == :tuple
                      prefix, tail = spec[1][1], spec[1][2]
                      value.each_with_index.map do |element, index|
                        sub = index < prefix.size ? prefix[index] : tail
                        sub.nil? ? [true, element] : coercion_result(element, sub)
                      end
                    else
                      value.map { |element| coercion_result(element, spec[1]) }
                    end
                  [results.all?(&:first), results.map(&:last)]
                when :map
                  return [false, value] unless value.is_a?(Hash)

                  results = value.transform_values { |entry| coercion_result(entry, spec[1]) }
                  [results.values.all?(&:first), results.transform_values(&:last)]
                when :try
                  begin
                    coercion_result(value, spec[1])
                  rescue KeyError
                    [false, value]
                  end
                when :pass
                  [true, value]
                when :union
                  if spec[1].any? { |sub| sub[0] == :try }
                    spec[1].each do |sub|
                      result = coercion_result(value, sub)
                      return result if result.first
                    end
                    [false, value]
                  else
                    spec[1].reduce([false, value]) do |(matched, converted), sub|
                      accepted, result = coercion_result(converted, sub)
                      [matched || accepted, result]
                    end
                  end
                end
              end
            end
          end
        RUBY
      end

      def rbs_code
        <<~RBS
          module #{@module_name}
            module CoercionHelper
          #{indent(coercers_rbs, 2)}

              def self.coerce_class_slot: (top value, top klass) -> top

              def self.coerce_spec: (top value, top spec) -> top

              def self.coercion_result: (top value, top spec) -> [bool, top]
            end
          end
        RBS
      end

      # The stdlib requires the built-in coercers need, one line each,
      # ahead of the module so the file loads on its own.
      def builtin_requires
        Schematrix::Coercers::BUILTIN
          .map { |coercer| "require #{coercer::GENERATED_REQUIRE.inspect}" }
          .uniq
          .join("\n")
      end

      # The built-in coercers as a Coercers module, one copy per output
      # directory. The bodies are the gem's own, so the helper and the
      # gem cannot drift apart.
      def coercers_ruby
        bodies =
          Schematrix::Coercers::BUILTIN.map do |coercer|
            <<~RUBY.rstrip
              module #{coercer.name.split("::").last}
              #{indent(coercer::GENERATED_BODY.rstrip, 1)}
              end
            RUBY
          end
        <<~RUBY.rstrip
          module Coercers
          #{indent(bodies.join("\n\n"), 1)}
          end
        RUBY
      end

      def coercers_rbs
        bodies =
          Schematrix::Coercers::BUILTIN.map do |coercer|
            <<~RBS.rstrip
              module #{coercer.name.split("::").last}
                def self.coerce: (top value) -> top
              end
            RBS
          end
        <<~RBS.rstrip
          module Coercers
          #{indent(bodies.join("\n\n"), 1)}
          end
        RBS
      end

      def indent(code, levels)
        prefix = "  " * levels
        code.lines.map { |line| line.strip.empty? ? line : prefix + line }.join
      end
    end
  end
end
