require_relative "test_helper"

require "tmpdir"

class TestRoundTrip < Minitest::Test
  include SchematrixTestHelper

  SCHEMA = <<~JSON
    {
      "type": "object",
      "properties": {
        "name": { "type": "string" },
        "age": { "type": "integer", "default": 42 },
        "$id": { "type": "string" },
        "address": {
          "type": "object",
          "properties": { "street": { "type": "string" } }
        },
        "tags": { "type": "array", "items": { "type": "string" } },
        "friends": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": { "name": { "type": "string" } }
          }
        },
        "vars": {
          "type": "object",
          "additionalProperties": { "$ref": "#/$defs/value" }
        }
      },
      "required": ["name"],
      "$defs": {
        "value": { "type": "object", "properties": { "v": { "type": "string" } } }
      }
    }
  JSON

  def test_from_h_loads_coerces_and_round_trips
    with_generated_class do |mod|
      person =
        mod::Schema.from_h(
          "name" => "Ada",
          "$id" => "https://example.com/person",
          "address" => {
            "street" => "Main",
          },
          "friends" => [{ "name" => "Grace" }, { "name" => "Alan" }],
          "vars" => {
            "x" => {
              "v" => "1",
            },
            "y" => true,
          },
          "extension" => "rides the catch-all",
        )

      assert_equal "Ada", person.name
      assert_equal "https://example.com/person", person.id
      assert_equal 42, person.age # absent: constructor default survives
      assert_kind_of mod::Schema::Props::Address, person.address
      assert_equal "Main", person.address.street
      assert_equal(
        [{ "name" => "Grace" }, { "name" => "Alan" }],
        person.friends.map(&:to_h),
      )
      assert_equal %w[Grace Alan], person.friends.map(&:name)
      assert_kind_of mod::Schema::Defs::Value, person.vars["x"]
      assert_equal "1", person.vars["x"].v
      assert_equal true, person.vars["y"] # booleans pass through raw
      assert_equal "rides the catch-all", person["extension"]

      dumped = person.to_h
      assert_equal "Ada", dumped["name"]
      assert_equal "https://example.com/person", dumped["$id"]
      assert_equal({ "street" => "Main" }, dumped["address"])
      assert_equal [{ "name" => "Grace" }, { "name" => "Alan" }],
                   dumped["friends"]
      assert_equal({ "x" => { "v" => "1" }, "y" => true }, dumped["vars"])
      assert_equal "rides the catch-all", dumped["extension"]
      assert_equal 42, dumped["age"] # defaults materialize in to_h

      reloaded = mod::Schema.from_h(dumped)
      assert_equal person.address.street, reloaded.address.street
      assert_equal person.friends.map(&:name), reloaded.friends.map(&:name)
      assert_equal "rides the catch-all", reloaded["extension"]
    end
  end

  def test_original_keys_inverts_the_name_mangling
    with_generated_class do |mod|
      assert_equal :id, mod::Schema::ORIGINAL_KEYS.fetch("$id")
      assert_equal :name, mod::Schema::ORIGINAL_KEYS.fetch("name")
    end
  end

  METACHARACTER_KEYS_SCHEMA = <<~'JSON'
    {
      "type": "object",
      "properties": {
        "x#{1+1}y": { "type": "integer" },
        "back\\slash": { "type": "string" },
        "quote\"inside": { "type": "string" }
      }
    }
  JSON

  def test_from_h_and_to_h_read_and_write_the_quoted_keys
    with_generated_class(METACHARACTER_KEYS_SCHEMA) do |mod|
      source = { "x\#{1+1}y" => 7, "back\\slash" => "v", 'quote"inside' => "w" }

      loaded = mod::Schema.from_h(source)
      assert_equal 7, loaded.x__1_1_y
      assert_equal "v", loaded.back_slash
      assert_equal "w", loaded.quote_inside

      dumped = loaded.to_h
      assert_equal source, dumped

      reloaded = mod::Schema.from_h(dumped)
      assert_equal 7, reloaded.x__1_1_y
      assert_equal "v", reloaded.back_slash
      assert_equal "w", reloaded.quote_inside
    end
  end

  private

  def with_generated_class(schema_source = SCHEMA)
    Dir.mktmpdir do |dir|
      schema = File.join(dir, "schema.json")
      File.write(schema, schema_source)
      output = File.join(dir, "out")
      Schematrix.generate(
        generators: [
          Schematrix::Generators::PlainRuby.new(output, "Gen"),
          Schematrix::Generators::AuxiliaryFiles.new(output, "Gen"),
        ],
        input_files: [schema],
      )

      Object.new.instance_eval do
        Dir["#{output}/**/*.rb"].each { |f| require f }
      end

      yield Gen
    ensure
      Gen.send(:remove_const, :Schema)
      Object.send(:remove_const, :Gen)
    end
  end
end
