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

  def test_plain_property_segments_drop_the_container
    name =
      resolver.class_name_from_path(
        locator_for("/schemas/order.json", "/properties/customer"),
      )

    assert_equal "Order::Customer", name
  end

  def test_defs_segments_drop_the_container_only
    name =
      resolver.class_name_from_path(
        locator_for("/schemas/order.json", "/$defs/Address"),
      )

    assert_equal "Order::Address", name
  end

  def test_property_named_defs_is_kept
    name =
      resolver.class_name_from_path(
        locator_for("/schemas/order.json", "/properties/$defs"),
      )

    assert_equal "Order::Defs", name
  end

  def test_defs_as_the_first_segment_cannot_wrap_around
    # A schema file literally named $defs.json used to read the last
    # segment through the index wraparound when checking for the
    # container position.
    name =
      resolver.class_name_from_path(
        locator_for("/schemas/$defs.json", "/properties/$defs"),
      )

    assert_equal "Defs::Defs", name
  end

  def test_dollar_prefixes_and_mangling_suffixes_strip
    name =
      resolver.class_name_from_path(
        locator_for("/schemas/meta.json", "/properties/$id"),
        "if_",
      )

    assert_equal "Meta::Id::If", name
  end
end
