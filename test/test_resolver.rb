require_relative "test_helper"

class TestResolver < Minitest::Test
  include SchematrixTestHelper

  def resolver
    Object.new.extend(Schematrix::Generators::Resolver)
  end

  def locator_for(path, fragment)
    uri = URI("file://#{path}")
    uri.fragment = fragment
    uri
  end

  def test_property_segments_encode_a_props_level
    name =
      resolver.class_name_from_path(
        locator_for("/schemas/order.json", "/properties/customer"),
      )

    assert_equal "Order::Props::Customer", name
  end

  def test_defs_segments_encode_a_defs_level
    name =
      resolver.class_name_from_path(
        locator_for("/schemas/order.json", "/$defs/Address"),
      )

    assert_equal "Order::Defs::Address", name
  end

  def test_property_and_defs_chains_never_fold
    properties =
      resolver.class_name_from_path(
        locator_for("/schemas/order.json", "/properties/address"),
      )
    defs =
      resolver.class_name_from_path(
        locator_for("/schemas/order.json", "/$defs/address"),
      )

    refute_equal properties, defs
  end

  def test_property_named_defs_encodes_both_levels
    name =
      resolver.class_name_from_path(
        locator_for("/schemas/order.json", "/properties/$defs"),
      )

    assert_equal "Order::Props::Defs", name
  end

  def test_defs_as_the_first_segment_is_the_file_name
    name =
      resolver.class_name_from_path(
        locator_for("/schemas/$defs.json", "/properties/$defs"),
      )

    assert_equal "Defs::Props::Defs", name
  end

  def test_dollar_prefixes_and_mangling_suffixes_strip
    name =
      resolver.class_name_from_path(
        locator_for("/schemas/meta.json", "/properties/$id"),
        "if_",
      )

    assert_equal "Meta::Props::Id::If", name
  end
end
