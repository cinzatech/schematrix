require_relative "../test_helper"

class TestComposition < Minitest::Test
  include SchematrixTestHelper

  def test_all_of_merge_plain_ruby
    assert_fixture("all_of_merge", "plain_ruby")
  end

  def test_all_of_merge_rbs
    assert_fixture("all_of_merge", "rbs")
  end

  def test_all_of_merge_sorbet_ruby
    assert_fixture("all_of_merge", "sorbet_ruby")
  end

  def test_all_of_merge_rbi
    assert_fixture("all_of_merge", "rbi")
  end

  def test_all_of_refs_plain_ruby
    assert_fixture("all_of_refs", "plain_ruby")
  end

  def test_all_of_refs_rbs
    assert_fixture("all_of_refs", "rbs")
  end

  def test_all_of_refs_sorbet_ruby
    assert_fixture("all_of_refs", "sorbet_ruby")
  end

  def test_all_of_refs_rbi
    assert_fixture("all_of_refs", "rbi")
  end

  def test_any_of_scalars_plain_ruby
    assert_fixture("any_of_scalars", "plain_ruby")
  end

  def test_any_of_scalars_rbs
    assert_fixture("any_of_scalars", "rbs")
  end

  def test_any_of_scalars_sorbet_ruby
    assert_fixture("any_of_scalars", "sorbet_ruby")
  end

  def test_any_of_scalars_rbi
    assert_fixture("any_of_scalars", "rbi")
  end

  def test_any_of_with_ref_plain_ruby
    assert_fixture("any_of_with_ref", "plain_ruby")
  end

  def test_any_of_with_ref_rbs
    assert_fixture("any_of_with_ref", "rbs")
  end

  def test_any_of_with_ref_sorbet_ruby
    assert_fixture("any_of_with_ref", "sorbet_ruby")
  end

  def test_any_of_with_ref_rbi
    assert_fixture("any_of_with_ref", "rbi")
  end

  def test_one_of_scalars_plain_ruby
    assert_fixture("one_of_scalars", "plain_ruby")
  end

  def test_one_of_scalars_rbs
    assert_fixture("one_of_scalars", "rbs")
  end

  def test_one_of_scalars_sorbet_ruby
    assert_fixture("one_of_scalars", "sorbet_ruby")
  end

  def test_one_of_scalars_rbi
    assert_fixture("one_of_scalars", "rbi")
  end

  def test_one_of_with_ref_plain_ruby
    assert_fixture("one_of_with_ref", "plain_ruby")
  end

  def test_one_of_with_ref_rbs
    assert_fixture("one_of_with_ref", "rbs")
  end

  def test_one_of_with_ref_sorbet_ruby
    assert_fixture("one_of_with_ref", "sorbet_ruby")
  end

  def test_one_of_with_ref_rbi
    assert_fixture("one_of_with_ref", "rbi")
  end

  def test_any_of_root_plain_ruby
    assert_fixture("any_of_root", "plain_ruby")
  end

  def test_any_of_root_rbs
    assert_fixture("any_of_root", "rbs")
  end

  def test_any_of_root_sorbet_ruby
    assert_fixture("any_of_root", "sorbet_ruby")
  end

  def test_any_of_root_rbi
    assert_fixture("any_of_root", "rbi")
  end

  def test_one_of_root_plain_ruby
    assert_fixture("one_of_root", "plain_ruby")
  end

  def test_one_of_root_rbs
    assert_fixture("one_of_root", "rbs")
  end

  def test_one_of_root_sorbet_ruby
    assert_fixture("one_of_root", "sorbet_ruby")
  end

  def test_one_of_root_rbi
    assert_fixture("one_of_root", "rbi")
  end

  def test_any_of_objects_plain_ruby
    assert_fixture("any_of_objects", "plain_ruby")
    assert_fixture("any_of_objects", "plain_ruby", path: "value")
  end

  def test_any_of_objects_rbs
    assert_fixture("any_of_objects", "rbs")
    assert_fixture("any_of_objects", "rbs", path: "value")
  end

  def test_any_of_objects_sorbet_ruby
    assert_fixture("any_of_objects", "sorbet_ruby")
    assert_fixture("any_of_objects", "sorbet_ruby", path: "value")
  end

  def test_any_of_objects_rbi
    assert_fixture("any_of_objects", "rbi")
    assert_fixture("any_of_objects", "rbi", path: "value")
  end

  def test_all_of_conflict_plain_ruby
    assert_fixture("all_of_conflict", "plain_ruby")
  end

  def test_all_of_conflict_rbs
    assert_fixture("all_of_conflict", "rbs")
  end

  def test_all_of_conflict_sorbet_ruby
    assert_fixture("all_of_conflict", "sorbet_ruby")
  end

  def test_all_of_conflict_rbi
    assert_fixture("all_of_conflict", "rbi")
  end

  def test_all_of_array_items_plain_ruby
    assert_fixture("all_of_array_items", "plain_ruby")
  end

  def test_all_of_array_items_rbs
    assert_fixture("all_of_array_items", "rbs")
  end

  def test_all_of_array_items_sorbet_ruby
    assert_fixture("all_of_array_items", "sorbet_ruby")
  end

  def test_all_of_array_items_rbi
    assert_fixture("all_of_array_items", "rbi")
  end
end
