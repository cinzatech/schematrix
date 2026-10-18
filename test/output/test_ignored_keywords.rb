require_relative "../test_helper"

class TestIgnoredKeywords < Minitest::Test
  include SchematrixTestHelper

  # Keywords without a codegen representation are ignored; the shapes
  # stay open, unevaluatedProperties: false does not close them.
  def test_ignored_keywords_plain_ruby
    assert_fixture("ignored_keywords", "plain_ruby")
  end

  def test_ignored_keywords_rbs
    assert_fixture("ignored_keywords", "rbs")
  end

  def test_ignored_keywords_sorbet_ruby
    assert_fixture("ignored_keywords", "sorbet_ruby")
  end

  def test_ignored_keywords_rbi
    assert_fixture("ignored_keywords", "rbi")
  end
end
