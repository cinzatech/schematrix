require_relative "test_helper"
require "tmpdir"

class TestGenerate < Minitest::Test
  include SchematrixTestHelper

  COLLIDING_SCHEMA = <<~JSON
    {
      "type": "object",
      "properties": {
        "address": {
          "type": "object",
          "properties": { "street": { "type": "string" } }
        },
        "alt": { "$ref": "#/$defs/address" }
      },
      "$defs": {
        "address": {
          "type": "object",
          "properties": { "city": { "type": "string" } }
        }
      }
    }
  JSON

  def test_colliding_names_generate_distinct_files
    Dir.mktmpdir do |dir|
      schema = File.join(dir, "colliding.json")
      File.write(schema, COLLIDING_SCHEMA)

      output = File.join(dir, "out")
      Schematrix.generate(
        generators: [
          Schematrix::Generators::PlainRuby.new(output, MODULE_NAME),
        ],
        input_files: [schema],
      )

      files =
        Dir
          .glob("#{output}/**/*.rb")
          .map { |path| path.delete_prefix("#{output}/") }
          .sort
      assert_equal(
        %w[colliding.rb colliding/defs/address.rb colliding/props/address.rb],
        files,
      )

      props = File.read(File.join(output, "colliding/props/address.rb"))
      defs = File.read(File.join(output, "colliding/defs/address.rb"))
      assert_match(/class Address/, props)
      assert_match(/def initialize\(street:/, props)
      assert_match(/def initialize\(city:/, defs)
    end
  end

  def test_paths_with_spaces_compile_and_generate
    Dir.mktmpdir do |dir|
      schema = write_schema(File.join(dir, "with space", "my doc.json"))

      output = File.join(dir, "out")
      Schematrix.generate(
        generators: [
          Schematrix::Generators::PlainRuby.new(output, MODULE_NAME),
        ],
        input_files: [schema],
      )

      generated = File.read(File.join(output, "my_doc.rb"))
      assert_match(/class MyDoc/, generated)
      assert_match(/def initialize\(id:/, generated)
    end
  end

  def test_same_basename_inputs_raise_before_writing
    Dir.mktmpdir do |dir|
      one = write_schema(File.join(dir, "one", "order.json"))
      two = write_schema(File.join(dir, "two", "order.json"))
      output = File.join(dir, "out")

      error =
        assert_raises(Schematrix::OutputCollisionError) do
          Schematrix.generate(
            generators: [
              Schematrix::Generators::PlainRuby.new(output, MODULE_NAME),
            ],
            input_files: [one, two],
          )
        end

      assert_match(/already claimed by/, error.message)
      assert_empty Dir.glob("#{output}/**/*")
    end
  end

  def test_same_extension_generators_in_one_directory_raise
    Dir.mktmpdir do |dir|
      schema = write_schema(File.join(dir, "order.json"))

      error =
        assert_raises(Schematrix::OutputCollisionError) do
          Schematrix.generate(
            generators: [
              Schematrix::Generators::PlainRuby.new(dir, MODULE_NAME),
              Schematrix::Generators::SorbetRuby.new(dir, MODULE_NAME),
            ],
            input_files: [schema],
          )
        end

      assert_match(/Generators::SorbetRuby writes/, error.message)
      assert_empty Dir.glob("#{dir}/*.rb")
    end
  end

  private

  def write_schema(path)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, <<~JSON)
      {
        "type": "object",
        "properties": { "id": { "type": "string" } }
      }
    JSON
    path
  end
end
