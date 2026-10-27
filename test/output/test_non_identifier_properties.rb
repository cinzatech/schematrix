require_relative "../test_helper"

class TestNonIdentifierProperties < Minitest::Test
  include SchematrixTestHelper

  # A property name that is not a plain identifier must fold to one
  # class name everywhere: the file that declares the nested class and
  # the parent that references it through its coercion delegation.
  def fixture_schema
    File.join(FIXTURES_DIR, "non_identifier_properties", "schema.json")
  end

  def slash_property_locator(name)
    "file://#{File.expand_path(fixture_schema)}#/properties/#{
      Schematrix::Pointer.escape(name)
    }"
  end

  def test_nested_class_names_agree_with_the_parent_plain_ruby
    assert_fixture("non_identifier_properties", "plain_ruby")
    assert_fixture(
      "non_identifier_properties",
      "plain_ruby",
      path: "first_name",
      locator: slash_property_locator("first name"),
    )
    assert_fixture(
      "non_identifier_properties",
      "plain_ruby",
      path: "a/b",
      locator: slash_property_locator("a/b"),
    )
  end

  def test_nested_class_names_agree_with_the_parent_rbs
    assert_fixture("non_identifier_properties", "rbs")
    assert_fixture(
      "non_identifier_properties",
      "rbs",
      path: "first_name",
      locator: slash_property_locator("first name"),
    )
    assert_fixture(
      "non_identifier_properties",
      "rbs",
      path: "a/b",
      locator: slash_property_locator("a/b"),
    )
  end

  def test_nested_class_names_agree_with_the_parent_sorbet_ruby
    assert_fixture("non_identifier_properties", "sorbet_ruby")
    assert_fixture(
      "non_identifier_properties",
      "sorbet_ruby",
      path: "first_name",
      locator: slash_property_locator("first name"),
    )
    assert_fixture(
      "non_identifier_properties",
      "sorbet_ruby",
      path: "a/b",
      locator: slash_property_locator("a/b"),
    )
  end

  def test_nested_class_names_agree_with_the_parent_rbi
    assert_fixture("non_identifier_properties", "rbi")
    assert_fixture(
      "non_identifier_properties",
      "rbi",
      path: "first_name",
      locator: slash_property_locator("first name"),
    )
    assert_fixture(
      "non_identifier_properties",
      "rbi",
      path: "a/b",
      locator: slash_property_locator("a/b"),
    )
  end

  # The compiled class registers at the escaped locator, so a loader
  # building its own URI from the percent-encoded pointer finds it.
  def test_first_name_property_registers_at_the_escaped_locator
    objects = compile_fixture("non_identifier_properties")

    locator = "file://#{File.expand_path(fixture_schema)}"
    assert_includes(objects.keys, "#{locator}#/properties/first%20name")
  end
end
