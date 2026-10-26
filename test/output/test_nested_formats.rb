require_relative "../test_helper"

class TestNestedFormats < Minitest::Test
  include SchematrixTestHelper

  def test_nested_formats_plain_ruby
    assert_fixture("nested_formats", "plain_ruby")
  end

  def test_nested_formats_sorbet_ruby
    assert_fixture("nested_formats", "sorbet_ruby")
  end

  def test_nested_formats_rbi
    assert_fixture("nested_formats", "rbi")
  end

  def test_nested_formats_rbs
    assert_fixture("nested_formats", "rbs")
  end
end
