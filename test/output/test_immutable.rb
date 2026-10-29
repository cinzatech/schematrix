require_relative "../test_helper"
require "tmpdir"

class TestImmutable < Minitest::Test
  include SchematrixTestHelper

  OPEN_SCHEMA = <<~JSON
    {
      "type": "object",
      "properties": {
        "name": { "type": "string" },
        "age": { "type": "integer", "default": 42 },
        "address": {
          "type": "object",
          "properties": { "street": { "type": "string" } }
        },
        "tags": { "type": "array", "items": { "type": "string" } }
      },
      "required": ["name"]
    }
  JSON

  CLOSED_SCHEMA = <<~JSON
    {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "name": { "type": "string" }
      }
    }
  JSON

  RESERVED_SCHEMA = <<~JSON
    {
      "type": "object",
      "properties": {
        "with": { "type": "string" },
        "_extra": { "type": "integer" },
        "hash": { "type": "string" }
      },
      "required": ["with"]
    }
  JSON

  def test_immutable_person_plain_ruby
    assert_fixture("immutable_person", "plain_ruby", immutable: true)
  end

  def test_immutable_person_sorbet_ruby
    assert_fixture("immutable_person", "sorbet_ruby", immutable: true)
  end

  def test_immutable_person_rbi
    assert_fixture("immutable_person", "rbi", immutable: true)
  end

  def test_immutable_person_rbs
    assert_fixture("immutable_person", "rbs", immutable: true)
  end

  def test_immutable_reserved_plain_ruby
    assert_fixture("immutable_reserved", "plain_ruby", immutable: true)
  end

  def test_immutable_reserved_sorbet_ruby
    assert_fixture("immutable_reserved", "sorbet_ruby", immutable: true)
  end

  def test_immutable_reserved_rbi
    assert_fixture("immutable_reserved", "rbi", immutable: true)
  end

  def test_immutable_reserved_rbs
    assert_fixture("immutable_reserved", "rbs", immutable: true)
  end

  def test_from_h_builds_a_frozen_tree
    with_generated_class(OPEN_SCHEMA) do |mod|
      person = mod::Schema.from_h("name" => "Ada", "nickname" => "Ada")

      assert_predicate person, :frozen?
      assert_equal 42, person.age
      assert_equal "Ada", person["nickname"]
    end
  end

  def test_writers_are_gone
    with_generated_class(OPEN_SCHEMA) do |mod|
      person = mod::Schema.from_h("name" => "Ada")

      assert_raises(NoMethodError) { person.age = 37 }
      assert_raises(NoMethodError) { person["nickname"] = "Ada" }
    end
  end

  def test_nested_classes_freeze_too
    with_generated_class(OPEN_SCHEMA) do |mod|
      person =
        mod::Schema.from_h("name" => "Ada", "address" => { "street" => "Main" })

      assert_predicate person.address, :frozen?
      assert_kind_of mod::Schema::Props::Address, person.address
    end
  end

  def test_with_copies_and_keeps
    with_generated_class(OPEN_SCHEMA) do |mod|
      person =
        mod::Schema.from_h(
          "name" => "Ada",
          "age" => 36,
          "address" => {
            "street" => "Main",
          },
          "extension" => "rides along",
        )

      older = person.with(age: 37)

      assert_predicate older, :frozen?
      assert_equal 37, older.age
      assert_equal 36, person.age
      assert_equal "Main", older.address.street
      assert_equal "rides along", older["extension"]

      moved = person.with(address: { "street" => "Oak" })

      assert_equal({ "street" => "Oak" }, moved.address)

      retagged = person.with(_extra: { "extension" => "replaced" })

      assert_equal "replaced", retagged["extension"]
      assert_equal 36, retagged.age
    end
  end

  def test_instances_behave_as_values
    with_generated_class(OPEN_SCHEMA) do |mod|
      person = mod::Schema.from_h("name" => "Ada")

      assert_equal person, person.with(age: 42)
      assert person.with(age: 42).eql?(person)
      refute_equal person, person.with(age: 43)
      refute_equal person, person.with(_extra: { "x" => 1 })
      refute_equal person, "Ada"
      refute_equal person,
                   mod::Schema::Props::Address.from_h("street" => "Main")

      assert_equal 1, [person, person.with(age: 42)].uniq.size
      assert_equal :hit, { person => :hit }[person.with(age: 42)]
    end
  end

  def test_eql_and_hash_agree
    with_generated_class(OPEN_SCHEMA) do |mod|
      person = mod::Schema.from_h("name" => "Ada")
      copy = person.with(age: 42)

      assert_equal person.hash, copy.hash
      assert_equal person, copy
    end
  end

  def test_extra_reader_is_protected
    with_generated_class(OPEN_SCHEMA) do |mod|
      person = mod::Schema.from_h("name" => "Ada", "x" => 1)

      assert_raises(NoMethodError) { person._extra }
    end
  end

  def test_round_trip_preserves_the_document
    with_generated_class(OPEN_SCHEMA) do |mod|
      person =
        mod::Schema.from_h(
          "name" => "Ada",
          "age" => 36,
          "address" => {
            "street" => "Main",
          },
          "nickname" => "Ada",
        )

      reloaded = mod::Schema.from_h(person.to_h)

      assert_equal person, reloaded
      assert_equal "Ada", reloaded["nickname"]
    end
  end

  def test_closed_shapes_stay_closed_to_reads_and_writes
    with_generated_class(CLOSED_SCHEMA) do |mod|
      closed = mod::Schema.from_h("name" => "Ada", "unknown" => 1)

      assert_equal "Ada", closed.name
      assert_raises(NoMethodError) { closed["unknown"] }
      assert_raises(ArgumentError) { closed.with(_extra: {}) }
      assert_equal({ "name" => "Ada" }, closed.to_h)
    end
  end

  def test_reserved_property_names_take_the_keyword_treatment
    with_generated_class(RESERVED_SCHEMA) do |mod|
      value =
        mod::Schema.from_h(
          "with" => "s",
          "_extra" => 7,
          "hash" => "abc",
          "other" => true,
        )

      assert_equal "s", value.with_
      assert_equal 7, value._extra_
      assert_equal "abc", value.hash_
      assert_kind_of Integer, value.hash

      rehashed = value.with(with_: "t", hash_: "def")

      assert_equal "t", rehashed.with_
      assert_equal "def", rehashed.hash_
      assert_equal "s", value.with_
      assert_equal "abc", value.hash_
      assert_equal(
        { "with" => "s", "_extra" => 7, "hash" => "abc", "other" => true },
        value.to_h,
      )
    end
  end

  def test_dsl_generators_reject_the_option
    Dir.mktmpdir do |dir|
      [
        Schematrix::Generators::DslPlainRuby,
        Schematrix::Generators::DslSorbetRuby,
        Schematrix::Generators::DslRbi,
        Schematrix::Generators::DslRbs,
      ].each do |generator_class|
        error =
          assert_raises(ArgumentError) do
            generator_class.new(dir, MODULE_NAME, immutable: true)
          end

        assert_match(/immutable applies to data generators/, error.message)
      end

      Schematrix::Generators::PlainRuby.new(dir, MODULE_NAME, immutable: true)
      Schematrix::Generators::SorbetRuby.new(dir, MODULE_NAME, immutable: true)
      Schematrix::Generators::Rbi.new(dir, MODULE_NAME, immutable: true)
      Schematrix::Generators::Rbs.new(dir, MODULE_NAME, immutable: true)
    end
  end

  private

  def with_generated_class(schema_source)
    Dir.mktmpdir do |dir|
      schema = File.join(dir, "schema.json")
      File.write(schema, schema_source)
      output = File.join(dir, "out")
      Schematrix.generate(
        generators: [
          Schematrix::Generators::PlainRuby.new(output, "Gen", immutable: true),
          Schematrix::Generators::AuxiliaryFiles.new(output, "Gen"),
        ],
        input_files: [schema],
      )

      Object.new.instance_eval do
        Dir["#{output}/**/*.rb"].each { |f| require f }
      end

      yield Gen
    ensure
      Gen.send(:remove_const, :Schema)
      Object.send(:remove_const, :Gen)
    end
  end
end
