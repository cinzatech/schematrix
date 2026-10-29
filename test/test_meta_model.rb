require_relative "test_helper"

require "tmpdir"

class TestMetaModel < Minitest::Test
  include SchematrixTestHelper

  METASCHEMA =
    File.join(
      SchematrixTestHelper::FIXTURES_DIR,
      "..",
      "..",
      "vendor/schemas/json-schema.org/draft/2020-12/schema",
    ).freeze

  COMMITTED = File.expand_path("../lib/schematrix/meta", __dir__).freeze

  def test_committed_model_matches_fresh_generation
    Dir.mktmpdir do |dir|
      Schematrix.generate(
        generators: [
          Schematrix::Generators::PlainRuby.new(
            dir,
            "Schematrix::Meta",
            command: "rake meta:generate",
          ),
          Schematrix::Generators::AuxiliaryFiles.new(
            dir,
            "Schematrix::Meta",
            command: "rake meta:generate",
          ),
        ],
        input_files: [METASCHEMA],
      )

      committed =
        Dir["#{COMMITTED}/**/*.rb"].map { |path| path.delete_prefix(COMMITTED) }
      fresh = Dir["#{dir}/**/*.rb"].map { |path| path.delete_prefix(dir) }

      assert_equal %w[/coercion_helper.rb /schema.rb], committed
      assert_equal committed, fresh

      committed.each_with_index do |relative, index|
        assert_equal(
          File.read(File.join(COMMITTED, relative)),
          File.read(File.join(dir, fresh[index])),
          "#{relative} is stale; run rake meta:generate and commit",
        )
      end
    end
  end

  def test_model_loads_and_navigates_a_meta_document
    doc = YAML.safe_load_file(meta_document_path("core"))
    model = Schematrix::Meta::Schema.from_h(doc)

    assert_equal "https://json-schema.org/draft/2020-12/meta/core", model.id
    assert_equal "meta", model.dynamic_anchor
    assert_equal %w[anchorString uriString uriReferenceString], model.defs.keys
    anchor = model.defs.fetch("anchorString")
    assert_kind_of Schematrix::Meta::Schema, anchor
    assert_equal "^[A-Za-z_][-A-Za-z0-9._]*$", anchor.pattern
    assert_kind_of Schematrix::Meta::Schema, model.properties.fetch("$id")

    dumped = model.to_h
    assert_contains_document(doc, dumped)
  end

  def test_model_is_one_recursive_class
    assert_kind_of Class, Schematrix::Meta::Schema
    assert_empty Schematrix::Meta.constants - %i[Schema CoercionHelper]
  end

  private

  # The model's from_h applies the metaschema's constructor defaults
  # (properties: {}, required: [], ...), so to_h materializes those
  # keys wherever a document omitted them. Round-trip fidelity is
  # therefore key-preservation with equal scalars, not byte
  # equality: no document fact may change or disappear.
  def assert_contains_document(original, dumped)
    assert_kind_of Hash, dumped
    original.each do |key, value|
      assert_includes dumped, key
      if value.is_a?(Hash)
        assert_contains_document(value, dumped.fetch(key))
      else
        assert_equal value, dumped.fetch(key)
      end
    end
  end

  def meta_document_path(name)
    File.join(File.dirname(METASCHEMA), "meta", name)
  end
end
