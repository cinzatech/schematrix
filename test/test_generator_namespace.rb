require_relative "test_helper"
require "tmpdir"
require "rbs"

class TestGeneratorNamespace < Minitest::Test
  def test_rejects_namespace_syntax_before_rendering
    invalid = [
      "Safe; raise 'injected'; module Unsafe",
      "Safe\nend\nraise 'injected'\nmodule Unsafe",
      "",
      "lowercase",
      "::",
      "::::Example",
      "Café; raise 'injected'",
      "Example::éclair",
      "Safe::",
      "Safe:::Nested",
      "Safe::lowercase",
      "Safe # comment",
      " Safe",
      "Safe\n",
      nil,
    ]
    Schematrix::GENERATORS.each_value do |generator|
      invalid.each do |name|
        assert_raises(ArgumentError, "#{generator}: #{name.inspect}") do
          generator.new("/tmp", name)
        end
      end
    end
  end

  def test_generated_namespaces_parse_and_round_trip
    %w[Café ::Example].each do |suffix|
      namespace = Module.new
      root = "NamespaceRegression#{namespace.object_id}"
      Object.const_set(root, namespace)
      leaf = suffix.delete_prefix("::")
      name = "#{root}::#{leaf}"
      name = "::#{name}" if suffix.start_with?("::")
      Dir.mktmpdir do |dir|
        path = File.join(dir, "schema.json")
        File.write(
          path,
          JSON.generate(
            {
              "type" => "object",
              "properties" => {
                "date" => {
                  "type" => "string",
                  "format" => "date",
                },
                "dates" => {
                  "type" => "array",
                  "items" => {
                    "type" => "string",
                    "format" => "date",
                  },
                },
              },
            },
          ),
        )
        Schematrix::GENERATORS.each_value do |generator_class|
          output = File.join(dir, generator_class.name.split("::").last)
          generators = [generator_class.new(output, name)]
          unless generator_class.run_once?
            generators << Schematrix::Generators::AuxiliaryFiles.new(
              output,
              name,
            )
          end
          Schematrix.generate(input_files: [path], generators:)
          Dir["#{output}/**/*.{rb,rbi,rbs}"].each do |file|
            code = File.read(file)
            refute_includes code, "::::"
            if file.end_with?(".rbs")
              RBS::Parser.parse_signature(code)
            else
              RubyVM::InstructionSequence.compile(code)
            end
          end
          next unless generator_class == Schematrix::Generators::PlainRuby

          require File.join(output, "schema.rb")
          source = { "date" => "2025-01-01", "dates" => ["2025-02-01"] }
          klass = namespace.const_get(leaf)::Schema
          assert_instance_of Date, klass.from_h(source).date
          assert_equal source, klass.from_h(source).to_h
        end
      end
    ensure
      if root && Object.const_defined?(root, false)
        Object.send(:remove_const, root)
      end
    end
  end

  def test_accepts_constant_paths
    Schematrix::GENERATORS.each_value do |generator|
      %w[
        Example
        Example::Nested
        ::Example::Nested
        Example_2
        Café
        Éxample::Café
      ].each do |name|
        assert_equal name.delete_prefix("::"),
                     generator.new("/tmp", name).module_name
      end
    end
  end
end
