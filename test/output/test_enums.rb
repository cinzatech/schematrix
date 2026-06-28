require_relative '../test_helper'

class TestEnums < Minitest::Test
  include SchematrixTestHelper
  def test_typed_string_enum_plain_ruby
    assert_fixture('typed_string_enum', 'plain_ruby')
  end

  def test_typed_string_enum_rbs
    assert_fixture('typed_string_enum', 'rbs')
  end

  def test_typed_string_enum_sorbet_ruby
    assert_fixture('typed_string_enum', 'sorbet_ruby')
  end

  def test_typed_string_enum_rbi
    assert_fixture('typed_string_enum', 'rbi')
  end
  def test_untyped_enum_plain_ruby
    assert_fixture('untyped_enum', 'plain_ruby')
  end

  def test_untyped_enum_rbs
    assert_fixture('untyped_enum', 'rbs')
  end

  def test_untyped_enum_sorbet_ruby
    assert_fixture('untyped_enum', 'sorbet_ruby')
  end

  def test_untyped_enum_rbi
    assert_fixture('untyped_enum', 'rbi')
  end
end
