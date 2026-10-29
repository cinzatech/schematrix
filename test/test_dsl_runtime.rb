require_relative "test_helper"

require "tmpdir"

class TestDslRuntime < Minitest::Test
  include SchematrixTestHelper

  SCHEMA = <<~JSON
    {
      "type": "object",
      "properties": {
        "name": { "type": "string" },
        "age": { "type": "integer" },
        "score": { "type": ["number", "null"] },
        "address": {
          "type": "object",
          "properties": { "street": { "type": "string" } }
        },
        "hobbies": { "type": "array", "items": { "type": "string" } },
        "friends": {
          "type": "array",
          "items": { "$ref": "#/$defs/person" }
        },
        "labels": {
          "type": "object",
          "additionalProperties": { "type": "integer" }
        },
        "metadata": {
          "type": "object",
          "additionalProperties": { "$ref": "#/$defs/person" }
        },
        "option": {
          "type": ["string", "object"],
          "properties": { "foo": { "type": "integer" } }
        },
        "mixed": {
          "type": "array",
          "items": {
            "anyOf": [{ "type": "string" }, { "$ref": "#/$defs/person" }]
          }
        },
        "matrix": {
          "type": "array",
          "items": { "type": "array", "items": { "type": "integer" } }
        }
      },
      "$defs": {
        "person": {
          "type": "object",
          "properties": { "name": { "type": "string" } }
        }
      }
    }
  JSON

  def test_build_produces_the_document_the_dsl_declares
    with_dsl_builders(SCHEMA, "L") do |mod|
      document =
        mod::Dsl::Schema.build do |schema|
          schema.name "Ada"
          schema.age 36
          schema.score 9.5

          schema.address { |address| address.street "1 Main St" }
          schema.address { |address| address.street "2 Main St" }

          schema.hobbies "chess", "programming"
          schema.hobbies "paper folding"

          schema.friends { |friend| friend.name "Grace Hopper" }
          schema.friends { |friend| friend.name "Alan Turing" }

          schema.labels "verified", true

          schema.metadata "mentor" do |mentor|
            mentor.name "Charles Babbage"
          end

          schema.option "fast"
          schema.option { |option| option.foo 1 }

          schema.mixed "scalar element"
          schema.mixed { |element| element.name "object element" }

          schema.matrix [1, 2], [3, 4]

          schema.extra "nickname", "Ada"
        end

      assert_equal(
        {
          "name" => "Ada",
          "age" => 36,
          "score" => 9.5,
          "address" => {
            "street" => "2 Main St",
          },
          "hobbies" => ["chess", "programming", "paper folding"],
          "friends" => [
            { "name" => "Grace Hopper" },
            { "name" => "Alan Turing" },
          ],
          "labels" => {
            "verified" => true,
          },
          "metadata" => {
            "mentor" => {
              "name" => "Charles Babbage",
            },
          },
          "option" => {
            "foo" => 1,
          },
          "mixed" => ["scalar element", { "name" => "object element" }],
          "matrix" => [[1, 2], [3, 4]],
          "nickname" => "Ada",
        },
        document,
      )
    end
  end

  def test_object_blocks_merge_when_the_slot_holds_a_hash
    with_dsl_builders(SCHEMA, "N") do |mod|
      document =
        mod::Dsl::Schema.build do |schema|
          schema.address { |address| address.street "1 Main St" }
          schema.address { |address| address.street "2 Main St" }
        end

      assert_equal({ "street" => "2 Main St" }, document["address"])
    end
  end

  def test_setters_chain_outside_blocks
    with_dsl_builders(SCHEMA, "P") do |mod|
      builder = mod::Dsl::Schema.new
      result = builder.name("Ada").age(36).hobbies("chess")

      assert_same builder, result
      assert_equal(
        { "name" => "Ada", "age" => 36, "hobbies" => ["chess"] },
        builder.to_h,
      )
    end
  end

  def test_reserved_method_names_take_the_keyword_treatment
    schema = <<~JSON
      {
        "type": "object",
        "properties": {
          "to_h": { "type": "string" },
          "extra": { "type": "string" },
          "build": { "type": "string" }
        }
      }
    JSON

    with_dsl_builders(schema, "R") do |mod|
      assert_equal(
        { "to_h" => :to_h_, "extra" => :extra_, "build" => :build_ },
        mod::Dsl::Schema::ORIGINAL_KEYS,
      )

      document =
        mod::Dsl::Schema.build do |schema|
          schema.to_h_ "reserved"
          schema.extra_ "also reserved"
          schema.build_ "still reserved"
        end

      assert_equal(
        {
          "to_h" => "reserved",
          "extra" => "also reserved",
          "build" => "still reserved",
        },
        document,
      )
    end
  end

  def test_dsl_builders_coexist_with_data_classes_and_feed_from_h
    Dir.mktmpdir do |dir|
      schema_file = File.join(dir, "schema.json")
      File.write(schema_file, SCHEMA)
      Schematrix.generate(
        generators: [
          Schematrix::Generators::PlainRuby.new(dir, "Co"),
          Schematrix::Generators::DslPlainRuby.new(dir, "Co"),
          Schematrix::Generators::AuxiliaryFiles.new(dir, "Co"),
        ],
        input_files: [schema_file],
      )
      Dir.glob("#{dir}/**/*.rb").each { |file| require file }

      document =
        Co::Dsl::Schema.build do |schema|
          schema.name "Ada"
          schema.address { |address| address.street "1 Main St" }
        end

      person = Co::Schema.from_h(document)
      assert_equal "Ada", person.name
      assert_kind_of Co::Schema::Props::Address, person.address
      assert_equal document, person.to_h
    end
  end

  private

  # Generates the DSL builders for the schema into a temp directory,
  # loads them, and yields the module they landed in. The module name
  # is required: `require` dedupes by path, so a second call under a
  # name already loaded would reopen and redefine those classes, with
  # a warning per method.
  def with_dsl_builders(schema_source, module_name)
    Dir.mktmpdir do |dir|
      schema_file = File.join(dir, "schema.json")
      File.write(schema_file, schema_source)

      Schematrix.generate(
        generators: [
          Schematrix::Generators::DslPlainRuby.new(dir, module_name),
        ],
        input_files: [schema_file],
      )
      Dir.glob("#{dir}/**/*.rb").each { |file| require file }

      yield Object.const_get(module_name)
    end
  end
end
