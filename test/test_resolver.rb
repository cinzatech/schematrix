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

  def test_fragment_percent_escapes_decode_before_folding
    name =
      resolver.class_name_from_path(
        locator_for("/schemas/order.json", "/properties/first%20name"),
      )

    assert_equal "Order::Props::FirstName", name
  end

  def test_an_escaped_slash_does_not_nest
    name =
      resolver.class_name_from_path(
        locator_for("/schemas/order.json", "/properties/a%2Fb"),
      )

    assert_equal "Order::Props::AB", name
  end

  def test_names_without_representable_characters_fold_to_hex
    name =
      resolver.class_name_from_path(
        locator_for("/schemas/order.json", "/properties/%E5%90%8D%E5%89%8D"),
      )

    assert_equal "Order::Props::E5908de5898d", name
  end

  def test_a_leading_digit_takes_the_n_prefix
    name =
      resolver.class_name_from_path(
        locator_for("/schemas/order.json", "/properties/2fa"),
      )

    assert_equal "Order::Props::N2fa", name
  end

  # The invariant behind issue #5: whatever a parent references
  # through the property's mangled name, the file written for the
  # property's locator must declare the same class.
  def test_mangled_name_and_locator_fold_to_one_class_name
    generator = Schematrix::Generators::PlainRuby.new("/tmp", "M")
    {
      "first name" => "first%20name",
      "a/b" => "a%2Fb",
      "a~1b" => Schematrix::Pointer.escape("a~1b"),
      "2fa" => "2fa",
      "@" => "%40",
      "pct%" => "pct%25",
      "名前" => "%E5%90%8D%E5%89%8D",
      "web.hook" => "web.hook",
      "foo-" => "foo-",
      "-" => "-",
      "_-" => "_-",
      "filter[name]" => "filter%5Bname%5D",
      "API key" => "API%20key",
      "HTTPServer" => "HTTPServer",
      "firstName" => "firstName",
    }.each do |key, escaped|
      from_locator =
        generator.class_name_from_path(
          locator_for("/schemas/order.json", "/properties/#{escaped}"),
        )
      from_parent =
        generator.class_name_from_path(
          locator_for("/schemas/order.json", "/"),
          "properties/#{generator.send(:property_name, key)}",
        )

      assert_equal from_locator, from_parent, key
    end
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
