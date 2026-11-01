require_relative "test_helper"

class TestEnumOptions < Minitest::Test
  def generator(enums = nil)
    Schematrix::Generators::PlainRuby.new("unused", "M", enums:)
  end

  def test_default_mode_is_unions
    assert_equal :unions, Schematrix.enum_mode([generator])
  end

  def test_explicit_mode_wins
    assert_equal :classes,
                 Schematrix.enum_mode([generator(:classes), generator])
    assert_equal :unions, Schematrix.enum_mode([generator(:unions)])
  end

  def test_conflicting_modes_fail
    assert_raises(ArgumentError) do
      Schematrix.enum_mode([generator(:classes), generator(:unions)])
    end
  end

  def test_invalid_modes_fail
    [:scalar, "classes", false].each do |mode|
      assert_raises(ArgumentError) { generator(mode) }
    end
  end
end
