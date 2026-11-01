require_relative "test_helper"
require "tmpdir"

class TestEnumRendering < Minitest::Test
  def test_class_types_and_nullable_slots
    rbs = render(:Rbs)
    assert_includes rbs, "attr_accessor status: Person::Props::Status?"
    assert_includes rbs,
                    "attr_accessor required_status: Person::Props::RequiredStatus"
    assert_includes rbs, "attr_accessor nullable: Person::Props::Nullable?"
    assert_includes rbs, "Array[Person::Props::Entries::Items]"
    assert_includes rbs,
                    "Hash[String, Person::Props::Labels::AdditionalProperties]"
    assert_includes rbs, "Person::Defs::Shared"
    sorbet = render(:SorbetRuby)
    assert_includes sorbet, "T.nilable(Person::Props::Status)"
    assert_includes sorbet, "T::Array[Person::Props::Entries::Items]"
    assert_includes sorbet,
                    "T::Hash[String, Person::Props::Labels::AdditionalProperties]"
    assert_includes render(:Rbi), "T.nilable(Person::Props::Nullable)"
  end

  def test_unions_and_formats
    rbs = render(:Rbs, enums: :unions, marked: false)
    assert_includes rbs, '("a" | "b")?'
    assert_includes rbs, "(1 | 2)?"
    assert_includes rbs, "attr_accessor date: Date?"
    sorbet = render(:SorbetRuby, enums: :unions, marked: false)
    assert_includes sorbet, "T.nilable(String)"
    assert_includes sorbet, "T.nilable(Date)"
    assert_includes render(:Rbs), "attr_accessor date: Person::Props::Date?"
    assert_includes render(:SorbetRuby), "T.nilable(Person::Props::Date)"
  end

  def test_partials_reference_unprefixed_enums
    assert_includes render(:PartialRbs), "M::Maybe[::M::Person::Props::Status?]"
    code = render(:PartialSorbetRuby)
    assert_includes code, "Maybe[T.nilable(::M::Person::Defs::Shared)]"
    refute_includes code, "Partial::Person::Props::Status"
    refute_includes code, "T.nilable(Partial::Person::Defs::Shared)"
  end

  def test_dsl_signatures_and_serialization_source
    code = render(:DslSorbetRuby)
    assert_includes code, "params(value: T.nilable(::M::Person::Props::Status))"
    assert_includes code, "params(value: ::M::Person::Props::RequiredStatus)"
    assert_includes code, "params(values: ::M::Person::Props::Entries::Items)"
    assert_includes code,
                    "value: ::M::Person::Props::Labels::AdditionalProperties"
    refute_includes code, "T.unsafe"
    assert_includes code, "enum_value = T.let(value, T.anything)"
    assert_match(
      /when ::M::Person::Props::Status\s+enum_value\.serialize\s+else\s+enum_value/,
      code,
    )
    assert_includes code, "values.map"
    assert_includes code, "when ::M::Person::Props::Entries::Items"
    assert_includes code,
                    "when ::M::Person::Props::Labels::AdditionalProperties"
    assert_includes code, "when ::M::Person::Defs::Shared"
    refute_includes code, "Defs::Shared.build"
    assert_includes render(:DslRbi),
                    "params(value: T.nilable(::M::Person::Props::Status))"
    assert_includes render(:DslRbs),
                    "def status: (::M::Person::Props::Status? value)"
    unions = render(:DslPlainRuby, enums: :unions)
    refute_includes unions, ".serialize"
    refute_includes unions, "Defs::Shared.build"
    assert_includes unions, "target.concat(values)"
    assert_includes unions, "target[key] = value"
  end

  def test_unmarked_records_do_not_reference_enum_classes
    code = render(:Rbs, marked: false)
    assert_includes code, "attr_accessor status: String?"
    refute_includes code, "Person::Props::Status"
  end

  def test_resolved_mode_overrides_explicit_and_default_modes
    assert_includes render(:Rbs, enums: nil, marked: false), '("a" | "b")?'
    assert_includes render(:Rbs, enums: :classes, resolved: :unions),
                    '("a" | "b")?'
    assert_includes render(:Rbs, enums: :unions, resolved: :classes),
                    "Person::Props::Status?"
  end

  private

  def enum
    { "type" => "string", "enum" => %w[a b] }
  end

  def document
    {
      "type" => "object",
      "additionalProperties" => false,
      "$defs" => {
        "shared" => enum,
      },
      "required" => %w[required_status nullable entries labels],
      "properties" => {
        "status" => enum,
        "required_status" => enum,
        "nullable" => {
          "enum" => [1, 2, nil],
        },
        "entries" => {
          "type" => "array",
          "items" => enum,
        },
        "labels" => {
          "type" => "object",
          "additionalProperties" => enum,
        },
        "shared" => {
          "$ref" => "#/$defs/shared",
        },
        "date" => {
          "enum" => %w[2025-01-01 2025-02-01],
          "format" => "date",
        },
      },
    }
  end

  def render(flavor, enums: :classes, marked: true, resolved: nil)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "person.json")
      File.write(path, JSON.generate(document))
      records = Schematrix::Compiler.new(enums_classes: marked).compile([path])
      locator, schema = records.find { |key, _| URI(key).fragment == "/" }
      generator = Schematrix::Generators.const_get(flavor).new(dir, "M", enums:)
      uri = URI(locator)
      options = resolved ? { enums: resolved } : {}
      generator.transform(
        uri,
        generator.class_name_from_path(uri),
        schema,
        **options,
      )
    end
  end
end
