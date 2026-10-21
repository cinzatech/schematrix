require_relative "test_helper"

require "prism"
require "tmpdir"

# A minimal Prism-based reconstructor implementing the parse contract
# from docs/dsl.md: it walks the builder calls of a DSL source file
# and rebuilds the document they declare, without running the file.
# The walker refuses any value that is not a literal, an array
# literal, or a hash literal, which is what keeps it total.
class DslSourceParser
  def initialize(contracts)
    @contracts = contracts
  end

  def parse(source)
    call = Prism.parse(source).value.statements.body.first
    unless call.is_a?(Prism::CallNode) && call.name == :build && call.block
      raise "not a builder entry point"
    end

    walk(call.block.body&.body || [], @contracts.fetch(:root))
  end

  private

  def walk(statements, contract)
    document = {}
    statements.each { |call| apply(call, document, contract) }
    document
  end

  def apply(call, document, contract)
    kind, key, child_key = contract.fetch(call.name.to_s)
    arguments = call.arguments&.arguments || []
    built =
      if call.block
        walk(call.block.body&.body || [], @contracts.fetch(child_key))
      end

    case kind
    when :scalar
      document[key] = literal(arguments.fetch(0))
    when :object
      document[key] = merge_built(document, key, built)
    when :array_scalars
      (document[key] ||= []).concat(
        arguments.map { |argument| literal(argument) },
      )
    when :array_objects
      (document[key] ||= []) << built
    when :mixed_array
      (document[key] ||= []).concat(
        arguments.map { |argument| literal(argument) },
      )
      document[key] << built if built
    when :map_scalars
      (document[key] ||= {})[literal(arguments.fetch(0))] = literal(
        arguments.fetch(1),
      )
    when :map_objects
      (document[key] ||= {})[literal(arguments.fetch(0))] = built
    when :mixed_value
      document[key] = (
        if built
          merge_built(document, key, built)
        else
          literal(arguments.fetch(0))
        end
      )
    when :extra_scalars
      document[literal(arguments.fetch(0))] = literal(arguments.fetch(1))
    when :extra_objects
      document[literal(arguments.fetch(0))] = built
    end
  end

  def merge_built(document, key, built)
    current = document[key]
    current.is_a?(Hash) ? current.merge(built) : built
  end

  def literal(node)
    case node
    when Prism::IntegerNode, Prism::FloatNode
      node.value
    when Prism::StringNode
      node.unescaped
    when Prism::TrueNode
      true
    when Prism::FalseNode
      false
    when Prism::NilNode
      nil
    when Prism::ArrayNode
      node.elements.map { |element| literal(element) }
    when Prism::HashNode, Prism::KeywordHashNode
      node.elements.to_h { |assoc| [literal(assoc.key), literal(assoc.value)] }
    else
      raise "non-literal value in DSL source: #{node.class}"
    end
  end
end

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

  # The parse contract for the schema above, per builder: method name
  # to [kind, original key, child contract]. This is the knowledge a
  # reconstructor carries for each schema; docs/dsl.md documents it.
  CONTRACTS = {
    root: {
      "name" => [:scalar, "name"],
      "age" => [:scalar, "age"],
      "score" => [:scalar, "score"],
      "address" => [:object, "address", :address],
      "hobbies" => [:array_scalars, "hobbies"],
      "friends" => [:array_objects, "friends", :person],
      "labels" => [:map_scalars, "labels"],
      "metadata" => [:map_objects, "metadata", :person],
      "option" => [:mixed_value, "option", :option],
      "mixed" => [:mixed_array, "mixed", :person],
      "matrix" => [:array_scalars, "matrix"],
      "extra" => [:extra_scalars],
    },
    address: {
      "street" => [:scalar, "street"],
    },
    option: {
      "foo" => [:scalar, "foo"],
    },
    person: {
      "name" => [:scalar, "name"],
    },
  }.freeze

  SOURCE = <<~RUBY
    M::Dsl::Schema.build do |schema|
      schema.name "Ada"
      schema.age 36
      schema.score 9.5

      schema.address do |address|
        address.street "1 Main St"
      end

      schema.hobbies "chess", "programming"
      schema.hobbies "paper folding"

      schema.friends do |friend|
        friend.name "Grace Hopper"
      end
      schema.friends do |friend|
        friend.name "Alan Turing"
      end

      schema.labels "verified", true

      schema.metadata "mentor" do |mentor|
        mentor.name "Charles Babbage"
      end

      schema.option "fast"
      schema.option do |option|
        option.foo 1
      end

      schema.mixed "scalar element"
      schema.mixed do |element|
        element.name "object element"
      end

      schema.matrix [1, 2], [3, 4]

      schema.extra "nickname", "Ada"
      schema.extra "config", { "retries" => 3 }
    end
  RUBY

  def test_parsing_reconstructs_what_running_produces
    parser = DslSourceParser.new(CONTRACTS)

    with_dsl_builders(SCHEMA) do
      # The comparison target is the test's own fixed source, so the
      # reconstruction is checked against real execution of the DSL.
      assert_equal eval(SOURCE), parser.parse(SOURCE) # rubocop:disable Security/Eval
    end
  end

  def test_non_literal_values_are_out_of_contract
    source = <<~RUBY
      M::Dsl::Schema.build do |schema|
        schema.age user_age
      end
    RUBY

    error =
      assert_raises(RuntimeError) do
        DslSourceParser.new(CONTRACTS).parse(source)
      end
    assert_match(/non-literal/, error.message)
  end

  private

  def with_dsl_builders(schema_source)
    Dir.mktmpdir do |dir|
      schema_file = File.join(dir, "schema.json")
      File.write(schema_file, schema_source)

      Schematrix.generate(
        generators: [Schematrix::Generators::DslPlainRuby.new(dir, "M")],
        input_files: [schema_file],
      )
      Dir.glob("#{dir}/**/*.rb").each { |file| require file }

      yield
    end
  end
end
