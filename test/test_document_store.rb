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

  def write_document(body)
    file = File.join(Dir.mktmpdir, "schema.yaml")
    File.write(file, body.is_a?(String) ? body : JSON.generate(body))
    file
  end
end
