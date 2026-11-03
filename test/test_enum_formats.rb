require_relative "test_helper"
require "tmpdir"

class TestEnumFormats < Minitest::Test
  def test_builtin_formats_compose_with_enum_membership
    [
      ["date", %w[2025-01-01 2025-02-01], Date],
      ["date-time", %w[2025-01-01T00:00:00Z 2025-02-01T00:00:00Z], Time],
    ].each do |format, values, type|
      with_generated(
        { "enum" => values, "format" => format },
      ) do |namespace, output|
        enum = namespace::Schema::Props::Value
        values.each do |raw|
          loaded = namespace::Schema.from_h("value" => raw)
          assert_instance_of type, loaded.value.serialize
          assert_same loaded.value, enum.deserialize(loaded.value.serialize)
          assert_equal({ "value" => raw }, loaded.to_h)
          assert_equal(
            { "value" => raw },
            namespace::Partial::Schema.from_h("value" => raw).to_h,
          )
          assert_equal(
            { "value" => raw },
            namespace::Dsl::Schema.build { value(loaded.value) },
          )
        end
        assert_raises(KeyError) do
          enum.coerce(values.first.sub("01-01", "03-01"))
        end
        signature = File.read(File.join(output, "schema/props/value.rbs"))
        assert_includes signature, "def serialize: -> ::#{type}"
      end
    end
  end

  def test_project_format_normalizes_before_membership
    with_namespace do |namespace|
      coercer = Module.new
      namespace.const_set(:Normalize, coercer)
      coercer.define_singleton_method(:coerce) do |value|
        value.is_a?(String) ? value.downcase : value
      end
      scalar_types = {
        %w[string normalized] =>
          Schematrix::ScalarType.new(sorbet: "String", rbs: "String", coercer:),
      }
      generate(
        namespace,
        { "enum" => %w[ACTIVE INACTIVE], "format" => "normalized" },
        scalar_types:,
      ) do |_output|
        enum = namespace::Schema::Props::Value
        assert_equal %w[active inactive], enum.values.map(&:serialize)
        loaded = namespace::Schema.from_h("value" => "AcTiVe")
        assert_same enum.deserialize("active"), loaded.value
        assert_equal({ "value" => "active" }, loaded.to_h)
        assert_raises(KeyError) do
          namespace::Schema.from_h("value" => "unknown")
        end
      end
    end
  end

  def test_integer_format_uses_the_same_conversion_sequence
    with_namespace do |namespace|
      coercer = Module.new
      namespace.const_set(:JulianDay, coercer)
      coercer.define_singleton_method(:coerce) do |value|
        case value
        when Integer
          Date.jd(value)
        when Date
          value.jd
        else
          value
        end
      end
      scalar_types = {
        %w[integer julian-day] =>
          Schematrix::ScalarType.new(sorbet: "Date", rbs: "Date", coercer:),
      }
      generate(
        namespace,
        { "enum" => [1, 2], "format" => "julian-day" },
        scalar_types:,
      ) do |_output|
        enum = namespace::Schema::Props::Value
        loaded = namespace::Schema.from_h("value" => 1)
        assert_same enum.deserialize(Date.jd(1)), loaded.value
        assert_equal Date.jd(1), loaded.value.serialize
        assert_equal({ "value" => 1 }, loaded.to_h)
        assert_raises(KeyError) { namespace::Schema.from_h("value" => 3) }
      end
    end
  end

  def test_formatted_enum_containers_round_trip
    enum = { "enum" => %w[2025-01-01 2025-02-01], "format" => "date" }
    [
      [{ "type" => "array", "items" => enum }, ["2025-01-01"]],
      [
        { "type" => "object", "additionalProperties" => enum },
        { "key" => "2025-02-01" },
      ],
    ].each do |shape, value|
      with_generated(shape) do |namespace, _output|
        source = { "value" => value }
        loaded = namespace::Schema.from_h(source)
        member =
          (
            if loaded.value.is_a?(Array)
              loaded.value.first
            else
              loaded.value.fetch("key")
            end
          )
        assert_instance_of Date, member.serialize
        assert_equal source, loaded.to_h
      end
    end
  end

  def test_reference_format_override_has_its_own_members
    reference = { "$ref" => "#/properties/value/$defs/date" }
    shape = {
      "type" => "object",
      "$defs" => {
        "date" => {
          "enum" => %w[2025-01-01 2025-02-01],
        },
      },
      "properties" => {
        "raw" => reference,
        "formatted" => reference.merge("format" => "date"),
      },
    }
    with_generated(shape) do |namespace, _output|
      source = {
        "value" => {
          "raw" => "2025-01-01",
          "formatted" => "2025-01-01",
        },
      }
      loaded = namespace::Schema.from_h(source)
      assert_instance_of String, loaded.value.raw.serialize
      assert_instance_of Date, loaded.value.formatted.serialize
      refute_same loaded.value.raw.class, loaded.value.formatted.class
      assert_equal source, loaded.to_h
    end
  end

  private

  def with_namespace
    namespace = Module.new
    name = "EnumFormats#{namespace.object_id}"
    Object.const_set(name, namespace)
    yield namespace
  ensure
    if name && Object.const_defined?(name, false)
      Object.send(:remove_const, name)
    end
  end

  def with_generated(shape)
    with_namespace do |namespace|
      generate(namespace, shape) { |output| yield namespace, output }
    end
  end

  def generate(namespace, shape, scalar_types: {})
    Dir.mktmpdir do |directory|
      path = File.join(directory, "schema.json")
      File.write(
        path,
        JSON.generate("type" => "object", "properties" => { "value" => shape }),
      )
      output = File.join(directory, "output")
      generators =
        %w[
          plain_ruby
          plain_ruby_enums
          dsl_plain_ruby
          partial_plain_ruby
          rbs
          rbs_enums
          auxiliary_files
        ].map do |flavor|
          Schematrix::GENERATORS.fetch(flavor).new(
            output,
            namespace.name,
            scalar_types:,
          )
        end
      Schematrix.generate(input_files: [path], generators:)
      Dir["#{output}/**/*.rb"].each { |file| require file }
      yield output
    end
  end
end
