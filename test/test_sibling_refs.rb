require_relative "test_helper"

require "tmpdir"

class TestSiblingRefs < Minitest::Test
  include SchematrixTestHelper

  # The OpenAPI 3.1 schema idiom: definitions carry a $ref beside
  # their own keywords (the vendor-extension hook), and other sites
  # reference the definitions. 2020-12 applies both, so a reference
  # into the definition targets the definition itself; the sibling
  # $ref applies when the definition compiles.
  SCHEMA = <<~JSON
    {
      "type": "object",
      "properties": {
        "info": { "$ref": "#/$defs/info" },
        "alt": { "$ref": "#/$defs/alias" },
        "described": { "$ref": "#/$defs/described" }
      },
      "required": ["info"],
      "$defs": {
        "info": {
          "type": "object",
          "properties": {
            "title": { "type": "string" },
            "contact": { "$ref": "#/$defs/contact" }
          },
          "required": ["title"],
          "$ref": "#/$defs/specification-extensions"
        },
        "contact": {
          "type": "object",
          "properties": { "email": { "type": "string" } },
          "$ref": "#/$defs/specification-extensions"
        },
        "specification-extensions": {
          "patternProperties": { "^x-": true }
        },
        "alias": { "$ref": "#/$defs/contact" },
        "described": {
          "$ref": "#/$defs/contact",
          "description": "annotation-only sibling"
        }
      }
    }
  JSON

  def test_sibling_ref_defs_register_their_classes
    objects, = compile_schema

    assert_equal(
      %w[/$defs/contact /$defs/info],
      objects.keys.map { |key| URI(key).fragment }.grep(%r{\A/\$defs}).sort,
    )
  end

  def test_pattern_properties_only_target_generates_no_class
    objects, = compile_schema

    assert_empty(objects.keys.grep(/specification-extensions/))
  end

  def test_slot_into_sibling_ref_def_keeps_the_ref
    objects, schema = compile_schema

    slot = objects.fetch(root_locator(schema).to_s).properties.fetch("info")
    assert_equal def_locator(schema, "info").to_s, slot.ref.to_s
    refute slot.untyped?
  end

  def test_sibling_ref_def_compiles_its_own_shape
    objects, schema = compile_schema

    info = objects.fetch(def_locator(schema, "info").to_s)
    assert_includes info.type, "object"
    assert info.properties.key?("title")
    assert info.properties.fetch("title").strictly_required?

    contact_slot = info.properties.fetch("contact")
    assert_equal def_locator(schema, "contact").to_s, contact_slot.ref.to_s
  end

  def test_chains_through_pure_refs_still_follow
    objects, schema = compile_schema

    slot = objects.fetch(root_locator(schema).to_s).properties.fetch("alt")
    assert_equal def_locator(schema, "contact").to_s, slot.ref.to_s
    assert_empty(objects.keys.grep(%r{\$defs/alias\z}))
  end

  def test_annotation_siblings_do_not_stop_the_chain
    objects, schema = compile_schema

    root = objects.fetch(root_locator(schema).to_s)
    slot = root.properties.fetch("described")
    assert_equal def_locator(schema, "contact").to_s, slot.ref.to_s
    assert_empty(objects.keys.grep(%r{\$defs/described\z}))
  end

  def test_generated_code_types_and_coerces_the_slot
    Dir.mktmpdir do |dir|
      schema = File.join(dir, "sibling_refs.json")
      File.write(schema, SCHEMA)
      output = File.join(dir, "out")
      Schematrix.generate(
        generators: [
          Schematrix::Generators::PlainRuby.new(output, MODULE_NAME),
          Schematrix::Generators::AuxiliaryFiles.new(output, MODULE_NAME),
        ],
        input_files: [schema],
      )

      files =
        Dir
          .glob("#{output}/**/*.rb")
          .map { |path| path.delete_prefix("#{output}/") }
          .sort
      assert_equal(
        %w[
          coercion_helper.rb
          sibling_refs.rb
          sibling_refs/defs/contact.rb
          sibling_refs/defs/info.rb
        ],
        files,
      )

      Dir["#{output}/**/*.rb"].each { |f| require f }
      info =
        M::SiblingRefs.from_h(
          "info" => {
            "title" => "Demo",
            "x-owner" => "platform",
          },
        ).info
      assert_instance_of M::SiblingRefs::Defs::Info, info
      assert_equal "Demo", info.title
      assert_equal "platform", info["x-owner"]
    ensure
      M.send(:remove_const, :Schema) if M.const_defined?(:Schema, false)
      Object.send(:remove_const, :M) if Object.const_defined?(:M, false)
    end
  end

  private

  # Compiles SCHEMA from a fresh temp file; returns the objects hash
  # and the schema path, so locators can be derived from it.
  def compile_schema
    Dir.mktmpdir do |dir|
      schema = File.join(dir, "sibling_refs.json")
      File.write(schema, SCHEMA)
      yield schema if block_given?
      [Schematrix::Compiler.new.compile([schema]), schema]
    end
  end

  def root_locator(schema)
    URI("file://#{File.expand_path(schema)}#/")
  end

  def def_locator(schema, name)
    URI("file://#{File.expand_path(schema)}#/$defs/#{name}")
  end
end
