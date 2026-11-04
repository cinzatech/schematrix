require_relative "test_helper"

require "prism"
require "tmpdir"

class TestDslPrism < Minitest::Test
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

  SOURCE = <<~RUBY
    M::Dsl::Schema.build do
      name "Ada"
      age 36
      score 9.5

      address do
        street "1 Main St"
      end

      hobbies "chess", "programming"
      hobbies "paper folding"

      friends do
        name "Grace Hopper"
      end
      friends do
        name "Alan Turing"
      end

      labels "verified", true

      metadata "mentor" do
        name "Charles Babbage"
      end

      option "fast"
      option do
        foo 1
      end

      mixed "scalar element"
      mixed do
        name "object element"
      end

      matrix [1, 2], [3, 4]

      extra "nickname", "Ada"
      extra "config", { "retries" => 3 }
    end
  RUBY

  def test_parsing_reconstructs_what_running_produces
    with_dsl_builders(SCHEMA) do
      assert_equal eval(SOURCE), M::Parser::Schema.parse(SOURCE) # rubocop:disable Security/Eval
    end
  end

  def test_non_literal_values_are_out_of_contract
    source = <<~RUBY
      M::Dsl::Schema.build do
        age user_age
      end
    RUBY

    with_dsl_builders(SCHEMA) do
      error =
        assert_raises(M::Parser::ParseError) { M::Parser::Schema.parse(source) }
      assert_match(/unsupported value expression/, error.message)
    end
  end

  private

  def with_dsl_builders(schema_source)
    Dir.mktmpdir do |dir|
      schema_file = File.join(dir, "schema.json")
      File.write(schema_file, schema_source)

      Schematrix.generate(
        generators: [
          Schematrix::Generators::DslPlainRuby.new(dir, "M"),
          Schematrix::Generators::DslParser.new(dir, "M"),
        ],
        input_files: [schema_file],
      )
      Dir.glob("#{dir}/**/*.rb").each { |file| require file }

      yield
    ensure
      Object.send(:remove_const, :M) if Object.const_defined?(:M)
    end
  end
end
