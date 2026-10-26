require_relative "../test_helper"

class TestRequiredNullable < Minitest::Test
  include SchematrixTestHelper

  # A property listed in required but typed ["string", "null"] takes a
  # required constructor keyword in every notation: the value may be
  # nil, the argument may not be omitted.
  def test_required_nullable_plain_ruby
    assert_fixture("required_nullable", "plain_ruby")
  end

  def test_required_nullable_rbs
    assert_fixture("required_nullable", "rbs")
  end

  def test_required_nullable_sorbet_ruby
    assert_fixture("required_nullable", "sorbet_ruby")
  end

  def test_required_nullable_rbi
    assert_fixture("required_nullable", "rbi")
  end
end
