require_relative "test_helper"

require "tmpdir"

class TestDocumentStore < Minitest::Test
  include SchematrixTestHelper

  def store
    Schematrix::DocumentStore.new
  end

  def locator(fragment)
    schema_file = File.join(FIXTURES_DIR, "any_of_scalars", "schema.json")
    URI("file://#{File.expand_path(schema_file)}##{fragment}")
  end

  def test_walks_object_pointers
    node = store.node_at(locator("/properties/value/anyOf/1"))

    assert_equal({ "type" => "integer" }, node)
  end

  def test_non_numeric_token_into_an_array_is_unresolvable
    error =
      assert_raises(Schematrix::UnresolvableLocatorError) do
        store.node_at(locator("/properties/value/anyOf/first"))
      end

    assert_match(/Nothing found at/, error.message)
  end

  def test_out_of_range_token_into_an_array_is_unresolvable
    error =
      assert_raises(Schematrix::UnresolvableLocatorError) do
        store.node_at(locator("/properties/value/anyOf/9"))
      end

    assert_match(/Nothing found at/, error.message)
  end

  def test_missing_token_into_an_object_is_unresolvable
    error =
      assert_raises(Schematrix::UnresolvableLocatorError) do
        store.node_at(locator("/properties/missing"))
      end

    assert_match(/Nothing found at/, error.message)
  end

  def test_percent_escapes_in_pointer_tokens_decode
    schema_file =
      File.join(FIXTURES_DIR, "non_identifier_properties", "schema.json")
    uri =
      URI("file://#{File.expand_path(schema_file)}#/properties/first%20name")
    node = store.node_at(uri)

    assert node.is_a?(Hash)
    assert node.key?("properties")
  end

  def test_tilde_escapes_in_pointer_tokens_decode
    schema_file =
      File.join(FIXTURES_DIR, "non_identifier_properties", "schema.json")
    uri = URI("file://#{File.expand_path(schema_file)}#/properties/a~1b")
    node = store.node_at(uri)

    assert node.is_a?(Hash)
    assert node.key?("properties")
  end
end

class TestDocumentValidation < Minitest::Test
  include SchematrixTestHelper

  def test_non_schema_document_is_refused_at_load
    ["just a string", "- one\n- two\n", "42"].each do |body|
      file = write_document(body)

      error =
        assert_raises(Schematrix::InvalidSchemaError) do
          store.node_at(root_locator(file))
        end

      assert_match(/not a schema document/, error.message)
    end
  end

  def test_empty_document_is_refused_at_load
    file = write_document("")

    error =
      assert_raises(Schematrix::InvalidSchemaError) do
        store.node_at(root_locator(file))
      end

    assert_match(/NilClass/, error.message)
  end

  def test_boolean_documents_load
    { "true" => true, "false" => false }.each do |body, expected|
      file = write_document(body)

      assert_equal expected, store.node_at(root_locator(file))
    end
  end

  def test_unsupported_dialect_is_refused_at_load
    unsupported = %w[
      http://json-schema.org/draft-07/schema#
      https://json-schema.org/draft/2019-09/schema
      https://example.com/dialect
    ]
    unsupported.each do |dialect|
      file = write_document({ "$schema" => dialect, "type" => "object" })

      error =
        assert_raises(Schematrix::UnsupportedDialectError) do
          store.node_at(root_locator(file))
        end

      assert_match(/declares dialect #{dialect}/, error.message)
      assert_match(/2020-12/, error.message)
    end
  end

  def test_supported_dialect_spellings_load
    supported = %w[
      https://json-schema.org/draft/2020-12/schema
      https://json-schema.org/draft/2020-12/schema#
      http://json-schema.org/draft/2020-12/schema
    ]
    supported.each do |dialect|
      file = write_document({ "$schema" => dialect, "type" => "object" })

      assert_equal "object", store.node_at(root_locator(file))["type"]
    end
  end

  CATALOG_DIALECT = "https://example.com/dialects/catalog"
  VOCAB = "https://json-schema.org/draft/2020-12/vocab"

  def test_custom_dialect_on_supported_vocabularies_loads
    dirs =
      schema_dirs_with(
        "example.com/dialects/catalog.json" => {
          "$schema" => CATALOG_DIALECT,
          "$vocabulary" => {
            "#{VOCAB}/core" => true,
            "#{VOCAB}/applicator" => true,
            "#{VOCAB}/validation" => true,
            "https://example.com/vocab/catalog" => false,
          },
        },
      )
    ["", "#"].each do |suffix|
      file =
        write_document(
          { "$schema" => "#{CATALOG_DIALECT}#{suffix}", "shelf" => "A12" },
        )
      store = Schematrix::DocumentStore.new(schema_dirs: dirs)

      assert_equal "A12", store.node_at(root_locator(file))["shelf"]
    end
  end

  def test_custom_dialect_without_a_local_metaschema_is_refused
    file = write_document({ "$schema" => CATALOG_DIALECT })
    dirs = schema_dirs_with({})

    error = assert_unsupported_dialect(file, dirs)

    assert_includes error.message, "declares dialect #{CATALOG_DIALECT}"
    assert_match(/no local file for the metaschema/, error.message)
    assert_includes error.message,
                    "#{dirs.first}/example.com/dialects/catalog.json"
  end

  def test_custom_dialect_without_vocabulary_is_refused
    file = write_document({ "$schema" => CATALOG_DIALECT })
    dirs =
      schema_dirs_with(
        "example.com/dialects/catalog.json" => {
          "$schema" => "https://json-schema.org/draft/2020-12/schema",
        },
      )

    error = assert_unsupported_dialect(file, dirs)

    assert_match(/has no \$vocabulary/, error.message)
  end

  def test_custom_dialect_requiring_an_unsupported_vocabulary_is_refused
    file = write_document({ "$schema" => CATALOG_DIALECT })
    dirs =
      schema_dirs_with(
        "example.com/dialects/catalog.json" => {
          "$vocabulary" => {
            "#{VOCAB}/core" => true,
            "#{VOCAB}/format-assertion" => true,
            "https://example.com/vocab/catalog" => true,
            "https://example.com/vocab/optional" => false,
          },
        },
      )

    error = assert_unsupported_dialect(file, dirs)

    assert_includes error.message,
                    "requires unsupported vocabularies: " \
                      "#{VOCAB}/format-assertion, " \
                      "https://example.com/vocab/catalog"
    refute_match(/optional/, error.message)
  end

  def test_older_draft_metaschema_in_the_schema_directory_is_refused
    older = "https://json-schema.org/draft/2019-09"
    file = write_document({ "$schema" => "#{older}/schema" })
    dirs =
      schema_dirs_with(
        "json-schema.org/draft/2019-09/schema.json" => {
          "$vocabulary" => {
            "#{older}/vocab/core" => true,
          },
        },
        "json-schema.org/draft-07/schema.json" => {
          "$schema" => "http://json-schema.org/draft-07/schema#",
        },
      )

    error = assert_unsupported_dialect(file, dirs)

    assert_includes error.message, "#{older}/vocab/core"

    file =
      write_document({ "$schema" => "http://json-schema.org/draft-07/schema#" })
    error = assert_unsupported_dialect(file, dirs)

    assert_match(/has no \$vocabulary/, error.message)
  end

  def test_dialect_that_cannot_map_to_a_local_file_is_refused
    dirs = schema_dirs_with({})
    %W[
      file:///tmp/dialect.json
      dialect.json
      urn:example:dialect
      #{CATALOG_DIALECT}#/$defs/inner
    ].each do |dialect|
      file = write_document({ "$schema" => dialect })

      error = assert_unsupported_dialect(file, dirs)

      assert_match(/http\(s\) URI without a fragment/, error.message)
    end
  end

  def test_custom_dialect_generates_the_same_code_as_the_default_dialect
    dirs =
      schema_dirs_with(
        "example.com/dialects/catalog.json" => {
          "$vocabulary" => {
            "#{VOCAB}/core" => true,
            "#{VOCAB}/applicator" => true,
            "#{VOCAB}/validation" => true,
            "https://example.com/vocab/catalog" => false,
          },
        },
      )
    file = File.join(Dir.mktmpdir, "product.json")
    outputs =
      [
        CATALOG_DIALECT,
        "https://json-schema.org/draft/2020-12/schema",
      ].map do |dialect|
        File.write(
          file,
          JSON.generate(
            {
              "$schema" => dialect,
              "type" => "object",
              "properties" => {
                "sku" => {
                  "type" => "string",
                },
              },
              "shelf" => "A12",
            },
          ),
        )
        output = Dir.mktmpdir
        Schematrix.generate(
          generators: [
            Schematrix::Generators::PlainRuby.new(output, MODULE_NAME),
          ],
          input_files: [file],
          schema_dirs: dirs,
        )
        Dir
          .glob("**/*", base: output)
          .sort
          .to_h do |path|
            full = File.join(output, path)
            [path, File.file?(full) ? File.read(full) : nil]
          end
      end

    refute_empty outputs.first
    assert_equal outputs.last, outputs.first
  end

  def test_document_without_header_loads_as_default_dialect
    file = write_document({ "type" => "string" })

    assert_equal({ "type" => "string" }, store.node_at(root_locator(file)))
  end

  private

  def store
    Schematrix::DocumentStore.new
  end

  def root_locator(file)
    URI("file://#{File.expand_path(file)}#/")
  end

  def schema_dirs_with(files)
    dir = Dir.mktmpdir
    files.each do |path, body|
      target = File.join(dir, path)
      FileUtils.mkdir_p(File.dirname(target))
      File.write(target, JSON.generate(body))
    end
    [dir]
  end

  def assert_unsupported_dialect(file, schema_dirs)
    assert_raises(Schematrix::UnsupportedDialectError) do
      Schematrix::DocumentStore.new(schema_dirs:).node_at(root_locator(file))
    end
  end

  def write_document(body)
    file = File.join(Dir.mktmpdir, "schema.yaml")
    File.write(file, body.is_a?(String) ? body : JSON.generate(body))
    file
  end
end
