module Schematrix
  module Generators
    # Writes the shared coercion helper module once per output
    # directory: the coerce_class_slot dispatcher and the coerce_spec
    # interpreter that generated classes call through qualified names.
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
      # literal travels with each delegation.
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
          module #{@module_name}
            module CoercionHelper
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
                case spec[0]
                when :coerce
                  spec[1].coerce(value)
                when :class
                  coerce_class_slot(value, spec[1])
                when :array
                  return value unless value.is_a?(Array)

                  if spec[1][0] == :tuple
                    prefix, tail = spec[1][1], spec[1][2]
                    value.each_with_index.map do |element, index|
                      sub = index < prefix.size ? prefix[index] : tail
                      sub.nil? ? element : coerce_spec(element, sub)
                    end
                  else
                    value.map { |element| coerce_spec(element, spec[1]) }
                  end
                when :map
                  return value unless value.is_a?(Hash)

                  value.transform_values { |entry| coerce_spec(entry, spec[1]) }
                when :union
                  spec[1].reduce(value) { |result, sub| coerce_spec(result, sub) }
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
              def self.coerce_class_slot: (top value, top klass) -> top

              def self.coerce_spec: (top value, top spec) -> top
            end
          end
        RBS
      end
    end
  end
end
