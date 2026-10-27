require_relative "../test_helper"

class TestAllOfValue < Minitest::Test
  include SchematrixTestHelper

  # allOf on a value schema conjoins into the slot's record: scalar
  # branches intersect their type terms, $ref branches keep their
  # target classes, and the referenced $defs classes are generated.
  def test_all_of_value_plain_ruby
    assert_fixture("all_of_value", "plain_ruby")
  end

  def test_all_of_value_rbs
    assert_fixture("all_of_value", "rbs")
  end

  def test_all_of_value_sorbet_ruby
    assert_fixture("all_of_value", "sorbet_ruby")
  end

  def test_all_of_value_rbi
    assert_fixture("all_of_value", "rbi")
  end

  def test_all_of_value_generates_the_referenced_defs_classes
    objects = compile_fixture("all_of_value")

    locators = objects.keys.grep(/defs/)
    assert_equal 2, locators.size
    assert(locators.any? { |locator| locator.end_with?("#/$defs/Base") })
    assert(locators.any? { |locator| locator.end_with?("#/$defs/Mixin") })
    # A map-shaped target inlines at the ref site: it generates no
    # class, and the slot renders a plain Hash instead.
    refute(locators.any? { |locator| locator.end_with?("#/$defs/Map") })
  end
end
