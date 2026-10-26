require_relative "../test_helper"

class TestMetacharacterKeys < Minitest::Test
  include SchematrixTestHelper

  # Property names carrying string-literal metacharacters: the
  # original keys must reach from_h/to_h as quoted literals, identical
  # to what ORIGINAL_KEYS records.
  def test_metacharacter_keys_plain_ruby
    assert_fixture("metacharacter_keys", "plain_ruby")
  end

  def test_metacharacter_keys_rbs
    assert_fixture("metacharacter_keys", "rbs")
  end

  def test_metacharacter_keys_sorbet_ruby
    assert_fixture("metacharacter_keys", "sorbet_ruby")
  end

  def test_metacharacter_keys_rbi
    assert_fixture("metacharacter_keys", "rbi")
  end
end
