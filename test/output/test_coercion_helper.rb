require_relative "../test_helper"

class TestCoercionHelper < Minitest::Test
  include SchematrixTestHelper

  def test_ruby_module
    assert_aux_golden("coercion_helper", "coercion_helper.rb")
  end

  def test_rbs_declarations
    assert_aux_golden("coercion_helper", "coercion_helper.rbs")
  end
end
