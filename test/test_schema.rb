require_relative "test_helper"

class TestSchema < Minitest::Test
  def test_shared_records_carry_frozen_type_sets
    assert_predicate Schematrix::Schema::Empty.type, :frozen?
    assert_predicate Schematrix::Schema::Bottom.type, :frozen?
  end

  def test_untyped_recognizes_only_truly_empty_schemas
    empty = Schematrix::Schema::Empty
    assert_predicate empty, :untyped?

    refute_predicate empty.with(ref: "file://x#/y"), :untyped?
    refute_predicate empty.with(type: Set[Schematrix::TYPE_STRING]), :untyped?
  end

  def test_strictly_required_demands_required_without_default_or_null
    schema = Schematrix::Schema::Empty

    refute_predicate schema, :strictly_required?

    required = schema.with(required: true)
    assert_predicate required, :strictly_required?

    refute_predicate required.with(default: 1), :strictly_required?
    refute_predicate required.with(type: Set[Schematrix::TYPE_NULL]),
                     :strictly_required?
  end
end
