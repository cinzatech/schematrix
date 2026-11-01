require_relative "test_helper"
require "tmpdir"

class TestEnumTuples < Minitest::Test
  def test_inline_tuple_enums_have_distinct_files_types_and_conversions
    Dir.mktmpdir do |directory|
      namespace = Module.new
      name = "EnumTuples#{namespace.object_id}"
      Object.const_set(name, namespace)
      path = File.join(directory, "record.json")
      File.write(
        path,
        JSON.generate(
          {
            "type" => "object",
            "additionalProperties" => false,
            "properties" => {
              "values" => {
                "type" => "array",
                "prefixItems" => [{ "enum" => %w[a b] }, { "enum" => [1, 2] }],
                "items" => false,
              },
            },
          },
        ),
      )
      output = File.join(directory, "out")
      generators =
        %w[
          plain_ruby
          plain_ruby_enums
          dsl_plain_ruby
          rbs
          auxiliary_files
        ].map { |key| Schematrix::GENERATORS.fetch(key).new(output, name) }
      records = Schematrix.generate(generators:, input_files: [path])
      enums = records.select { |_key, node| node.enum_class? }
      expected = %w[
        /properties/values/prefixItems/0
        /properties/values/prefixItems/1
      ]
      assert_equal(expected, enums.keys.map { |key| URI(key).fragment })
      Dir.glob("#{output}/**/*.rb").each { |file| require file }
      first = namespace.const_get("Record::Props::Values::PrefixItems::N0")
      second = namespace.const_get("Record::Props::Values::PrefixItems::N1")
      instance = namespace::Record.from_h("values" => ["a", 2])
      assert_same first::A, instance.values.first
      assert_same second::N2, instance.values.last
      assert_equal({ "values" => ["a", 2] }, instance.to_h)
      assert_equal instance.to_h, namespace::Record.from_h(instance.to_h).to_h
      assert_raises(KeyError) do
        namespace::Record.from_h("values" => ["bad", 2])
      end
      builder = namespace::Dsl::Record.new
      builder.values(first::A)
      builder.values(second::N2)
      assert_equal instance.to_h, builder.to_h
      builder = namespace::Dsl::Record.new
      builder.values("a", 2)
      assert_equal instance.to_h, builder.to_h
      signatures = File.read(File.join(output, "record.rbs"))
      assert_includes signatures, "Record::Props::Values::PrefixItems::N0"
      assert_includes signatures, "Record::Props::Values::PrefixItems::N1"
    ensure
      Object.send(:remove_const, name) if name
    end
  end
end
