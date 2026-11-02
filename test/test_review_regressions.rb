require_relative "test_helper"
require "json"
require "tmpdir"

class TestReviewRegressions < Minitest::Test
  def test_recursive_map_references_compile
    schema = {
      "type" => "object",
      "properties" => {
        "tree" => {
          "$ref" => "#/$defs/tree",
        },
      },
      "$defs" => {
        "tree" => {
          "type" => "object",
          "additionalProperties" => {
            "$ref" => "#/$defs/tree",
          },
        },
      },
    }
    with_schema(schema) do |path|
      root = Schematrix::Compiler.new.compile([path]).values.first
      assert_predicate root.properties.fetch("tree"), :map_shaped?
    end
    with_generated(schema) do |namespace|
      source = { "tree" => { "branch" => { "leaf" => {} } } }
      assert_equal source, namespace::Schema.from_h(source).to_h
    end
    with_schema(
      "type" => "object",
      "additionalProperties" => {
        "$ref" => "#",
      },
    ) { |path| assert_empty Schematrix::Compiler.new.compile([path]) }
  end

  def test_nested_object_composition_retains_properties
    schema = {
      "type" => "object",
      "allOf" => [
        { "allOf" => [{ "properties" => { "x" => { "type" => "string" } } }] },
      ],
    }
    with_schema(schema) do |path|
      objects = Schematrix::Compiler.new.compile([path])
      refute_empty objects
      assert_equal Set["string"],
                   objects.values.first.properties.fetch("x").type
    end
  end

  def test_nested_composition_through_recursive_reference
    schema = {
      "type" => "object",
      "allOf" => [{ "$ref" => "#/$defs/base" }],
      "$defs" => {
        "base" => {
          "allOf" => [
            { "properties" => { "x" => { "type" => "string" } } },
            { "$ref" => "#/$defs/base" },
          ],
        },
      },
    }
    with_schema(schema) do |path|
      root = Schematrix::Compiler.new.compile([path]).values.first
      assert_equal Set["string"], root.properties.fetch("x").type
    end
  end

  def test_immutable_maybe_preserves_presence
    schema = object_schema("name" => { "type" => %w[string null] })
    with_generated(schema, immutable: true, optionals: :maybe) do |namespace|
      [{}, { "name" => nil }, { "name" => "Ada" }].each do |source|
        loaded = namespace::Schema.from_h(source)
        assert_equal source.key?("name"), loaded.name.present?
        assert_equal source, loaded.to_h
      end
    end
  end

  def test_formatted_enum_loads_and_dumps_members
    schema =
      object_schema(
        "value" => {
          "enum" => %w[2025-01-01 2025-02-01],
          "format" => "date",
        },
      )
    with_generated(schema, enum_classes: true) do |namespace|
      klass = namespace::Schema
      member = klass::Props::Value.values.first
      loaded = klass.from_h("value" => member.serialize)
      assert_same member, loaded.value
      assert_equal(
        { "value" => member.serialize },
        klass.new(value: member).to_h,
      )
    end
  end

  def test_structural_enum_unions_accept_each_branch
    values = %w[a c]
    %w[array object].each do |type|
      child = type == "array" ? "items" : "additionalProperties"
      schema =
        object_schema(
          "value" => {
            "anyOf" => [
              { "type" => type, child => { "enum" => %w[a b] } },
              { "type" => type, child => { "enum" => %w[c d] } },
            ],
          },
        )
      with_generated(schema, enum_classes: true) do |namespace|
        values.each do |value|
          source = { "value" => type == "array" ? [value] : { "key" => value } }
          assert_equal source, namespace::Schema.from_h(source).to_h
        end
      end
    end
  end

  def test_conditional_properties_are_optional
    branch = {
      "properties" => {
        "y" => {
          "type" => "string",
        },
      },
      "required" => ["y"],
    }
    [
      { "if" => { "required" => ["x"] }, "then" => branch },
      { "if" => { "required" => ["x"] }, "else" => branch },
      { "dependentSchemas" => { "x" => branch } },
    ].each do |condition|
      schema = object_schema("x" => { "type" => "string" }).merge(condition)
      with_schema(schema) do |path|
        root = Schematrix::Compiler.new.compile([path]).values.first
        refute root.properties.fetch("y").required
      end
    end
  end

  def test_initialize_property_does_not_replace_constructor
    with_generated(
      object_schema("initialize" => { "type" => "string" }),
    ) do |namespace|
      source = { "initialize" => "hello" }
      assert_equal source, namespace::Schema.from_h(source).to_h
    end
  end

  def test_reference_to_empty_property_name
    schema =
      object_schema(
        "" => {
          "type" => "string",
        },
        "value" => {
          "$ref" => "#/properties/",
        },
      )
    with_schema(schema) do |path|
      root = Schematrix::Compiler.new.compile([path]).values.first
      assert_equal Set["string"], root.properties.fetch("value").type
    end
  end

  private

  def object_schema(properties)
    {
      "type" => "object",
      "properties" => properties,
      "additionalProperties" => false,
    }
  end

  def with_schema(schema)
    Dir.mktmpdir do |directory|
      path = File.join(directory, "schema.json")
      File.write(path, JSON.generate(schema))
      yield path
    end
  end

  def with_generated(schema, enum_classes: false, **)
    namespace = Module.new
    name = "ReviewRegression#{namespace.object_id}"
    Object.const_set(name, namespace)
    with_schema(schema) do |path|
      Dir.mktmpdir do |output|
        generators = [
          Schematrix::Generators::PlainRuby.new(output, name, **),
          Schematrix::Generators::AuxiliaryFiles.new(output, name),
        ]
        if enum_classes
          generators << Schematrix::Generators::PlainRubyEnums.new(output, name)
        end
        Schematrix.generate(input_files: [path], generators:)
        Dir["#{output}/**/*.rb"].each { |file| require file }
        yield namespace
      end
    end
  ensure
    if name && Object.const_defined?(name, false)
      Object.send(:remove_const, name)
    end
  end
end
