require_relative "test_helper"

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
end
