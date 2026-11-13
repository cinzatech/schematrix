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
        mod::Dsl::Schema.build do
          name "Ada"
          age 36
          score 9.5

          address { street "1 Main St" }
          address { street "2 Main St" }

          hobbies "chess", "programming"
          hobbies "paper folding"

          friends { name "Grace Hopper" }
          friends { name "Alan Turing" }

          labels "verified", true

          metadata "mentor" do
            name "Charles Babbage"
          end

          option "fast"
          option { foo 1 }

          mixed "scalar element"
          mixed { name "object element" }

          matrix [1, 2], [3, 4]

          extra "nickname", "Ada"
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
        mod::Dsl::Schema.build do
          address { street "1 Main St" }
          address { street "2 Main St" }
        end

      assert_equal({ "street" => "2 Main St" }, document["address"])
    end
  end

  def test_object_setters_without_a_block_declare_an_empty_object
    with_dsl_builders(SCHEMA, "EmptyObjects") do |mod|
      document =
        mod::Dsl::Schema.build do
          address
          friends
          metadata "mentor"
        end

      assert_equal({}, document["address"])
      assert_equal [{}], document["friends"]
      assert_equal({ "mentor" => {} }, document["metadata"])
      assert_equal %w[address friends metadata], document.keys
    end
  end

  def test_blockless_object_setters_follow_the_repeat_rules
    with_dsl_builders(SCHEMA, "EmptyRepeats") do |mod|
      document =
        mod::Dsl::Schema.build do
          address { street "1 Main St" }
          address

          friends
          friends { name "Grace Hopper" }
          friends

          metadata("mentor") { name "Charles Babbage" }
          metadata "mentor"
        end

      assert_equal({ "street" => "1 Main St" }, document["address"])
      assert_equal [{}, { "name" => "Grace Hopper" }, {}], document["friends"]
      assert_equal({ "mentor" => {} }, document["metadata"])
    end
  end

  def test_blockless_mixed_array_declares_an_empty_array
    with_dsl_builders(SCHEMA, "EmptyMixed") do |mod|
      assert_equal({ "mixed" => [] }, mod::Dsl::Schema.build { mixed })
    end
  end

  def test_setters_chain_outside_blocks
    with_dsl_builders(SCHEMA, "P") do |mod|
      builder = mod::Dsl::Schema::Builder.new
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
          "build": { "type": "string" },
          "dsl_fields": { "type": "string" }
        }
      }
    JSON

    with_dsl_builders(schema, "R") do |mod|
      assert_equal(
        {
          "to_h" => :to_h_,
          "extra" => :extra_,
          "build" => :build_,
          "dsl_fields" => :dsl_fields_,
        },
        mod::Dsl::Schema::ORIGINAL_KEYS,
      )

      document =
        mod::Dsl::Schema.build do
          to_h_ "reserved"
          extra_ "also reserved"
          build_ "still reserved"
          dsl_fields_ "reserved too"
        end

      assert_equal(
        {
          "to_h" => "reserved",
          "extra" => "also reserved",
          "build" => "still reserved",
          "dsl_fields" => "reserved too",
        },
        document,
      )
    end
  end

  def test_a_class_extended_with_a_builder_declares_in_its_body
    with_dsl_builders(SCHEMA, "X") do |mod|
      declaration =
        Class.new do
          extend mod::Dsl::Schema

          name "Ada"
          hobbies "chess"
          address { street "1 Main St" }
        end

      assert_equal(
        {
          "name" => "Ada",
          "hobbies" => ["chess"],
          "address" => {
            "street" => "1 Main St",
          },
        },
        declaration.to_h,
      )
    end
  end

  def test_a_builder_named_builder_loads_and_builds
    schema = <<~JSON
      {
        "type": "object",
        "properties": {
          "builder": {
            "type": "object",
            "properties": { "name": { "type": "string" } }
          }
        }
      }
    JSON

    with_dsl_builders(schema, "Bn") do |mod|
      document = mod::Dsl::Schema.build { builder { name "Ada" } }

      assert_equal({ "builder" => { "name" => "Ada" } }, document)
      assert_kind_of mod::Dsl::Schema::Props::Builder,
                     mod::Dsl::Schema::Props::Builder::Builder.new
    end
  end

  def test_a_frozen_builder_still_answers_to_h
    with_dsl_builders(SCHEMA, "Fr") do |mod|
      builder = mod::Dsl::Schema::Builder.new.name("Ada").freeze

      assert_equal({ "name" => "Ada" }, builder.to_h)
    end
  end

  def test_a_property_description_comments_its_setter_in_every_flavour
    schema = <<~JSON
      {
        "type": "object",
        "properties": {
          "name": { "type": "string", "description": "The display name." },
          "age": { "type": "integer" }
        }
      }
    JSON
    flavours = %w[dsl_plain_ruby dsl_sorbet_ruby dsl_rbi dsl_rbs]
    sig = "sig { params(value: String).returns(T.self_type) }"
    expected = {
      "dsl_plain_ruby" => ["def name(value)"],
      "dsl_sorbet_ruby" => [sig, "def name(value)"],
      "dsl_rbi" => [sig, "def name(value)"],
      "dsl_rbs" => ["def name: (String value) -> instance"],
    }

    Dir.mktmpdir do |dir|
      schema_file = File.join(dir, "schema.json")
      File.write(schema_file, schema)
      generators =
        flavours.map do |name|
          Schematrix::GENERATORS.fetch(name).new(File.join(dir, name), "Dc")
        end
      Schematrix.generate(generators:, input_files: [schema_file])

      flavours.each do |name|
        extension = Schematrix::GENERATORS.fetch(name).file_extension
        source = File.read(File.join(dir, name, "dsl/schema#{extension}"))
        commented = ["# The display name.", *expected.fetch(name)]

        assert_includes source, commented.join("\n      "), name
        refute_includes source, "# The display name.\n      def age", name
      end
    end
  end

  def test_an_object_including_a_builder_builds_its_own_document
    with_dsl_builders(SCHEMA, "I") do |mod|
      holder = Class.new { include mod::Dsl::Schema }
      first = holder.new.name("Ada")
      second = holder.new.name("Grace")

      assert_equal({ "name" => "Ada" }, first.to_h)
      assert_equal({ "name" => "Grace" }, second.to_h)
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
        Co::Dsl::Schema.build do
          name "Ada"
          address { street "1 Main St" }
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
