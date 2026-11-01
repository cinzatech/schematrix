require_relative "test_helper"
require "tmpdir"

class TestEnumIntegration < Minitest::Test
  include SchematrixTestHelper

  def test_class_usage_goldens
    %w[rbs sorbet_ruby partial_rbs dsl_rbs dsl_plain_ruby].each do |flavor|
      assert_fixture("enum_usage", flavor, enums: :classes)
    end
  end

  def test_fixture_helper_marks_enum_writer_nodes_in_both_usage_modes
    assert_fixture("enum_usage", "rbs_enums", path: "status")
    assert_fixture("enum_usage", "rbs_enums", path: "status", enums: :unions)
  end

  def test_data_round_trip_through_the_pipeline
    with_generated do |namespace, output|
      klass = namespace::Schema
      affiliation = klass::Defs::Affiliation
      source = source_hash
      loaded = klass.from_h(source)

      assert_same klass::Props::Status::Active, loaded.status
      assert_same klass::Props::Rank::N2, loaded.rank
      assert_same affiliation::Employee, loaded.affiliation
      assert_same loaded.affiliation, loaded.second
      assert_equal [affiliation::Employee, affiliation::External],
                   loaded.statuses
      assert_same affiliation::External, loaded.labels.fetch("owner")
      assert_nil loaded.nullable
      assert_equal source, loaded.to_h
      reloaded = klass.from_h(loaded.to_h)
      assert_same loaded.status, reloaded.status
      assert_same loaded.affiliation, reloaded.affiliation
      assert_same loaded.statuses.last, reloaded.statuses.last
      assert_same loaded.labels.fetch("owner"), reloaded.labels.fetch("owner")
      assert_same klass::Props::Nullable::Yes,
                  klass.from_h(source.merge("nullable" => "yes")).nullable

      %w[status affiliation rank]
        .zip(["missing", "missing", 99])
        .each do |key, value|
          assert_raises(KeyError) { klass.from_h(source.merge(key => value)) }
        end
      assert_raises(KeyError) do
        klass.from_h(source.merge("statuses" => ["missing"]))
      end
      assert_raises(KeyError) do
        klass.from_h(source.merge("labels" => { "owner" => "missing" }))
      end
      assert_equal 1, Dir["#{output}/**/affiliation.rb"].size
      assert File.file?(File.join(output, "coercion_helper.rb"))
    end
  end

  def test_dsl_serializes_members_on_store_and_keeps_raw_values
    with_generated do |namespace, _output|
      klass = namespace::Schema
      affiliation = klass::Defs::Affiliation
      builder = namespace::Dsl::Schema.new
      assert_same builder, builder.status(klass::Props::Status::Active)
      builder.affiliation(affiliation::Employee)
      builder.second(affiliation::Employee)
      builder.statuses(affiliation::Employee, affiliation::External)
      builder.labels("owner", affiliation::External)
      builder.rank(klass::Props::Rank::N2)
      builder.nullable(nil)
      assert_equal source_hash.merge("nullable" => nil), builder.to_h
      assert_same affiliation::Employee, klass.from_h(builder.to_h).affiliation

      builder.status("inactive")
      builder.statuses("external")
      builder.labels("owner", "employee")
      assert_equal "inactive", builder.to_h.fetch("status")
      assert_equal %w[employee external external],
                   builder.to_h.fetch("statuses")
      assert_equal({ "owner" => "employee" }, builder.to_h.fetch("labels"))
    end
  end

  def test_partial_maybe_converts_enum_values_and_preserves_presence
    with_generated do |namespace, _output|
      klass = namespace::Partial::Schema
      affiliation = namespace::Schema::Defs::Affiliation
      source = source_hash.merge("nullable" => nil)
      loaded = klass.from_h(source)
      assert_predicate loaded.status, :present?
      loaded.status.when_present do |member|
        assert_same namespace::Schema::Props::Status::Active, member
      end
      loaded.affiliation.when_present do |member|
        assert_same affiliation::Employee, member
      end
      loaded.statuses.when_present do |members|
        assert_equal [affiliation::Employee, affiliation::External], members
      end
      loaded.labels.when_present do |members|
        assert_same affiliation::External, members.fetch("owner")
      end
      assert_predicate loaded.nullable, :present?
      loaded.nullable.when_present { |value| assert_nil value }
      assert_equal source, loaded.to_h
      assert_equal source, klass.from_h(loaded.to_h).to_h
      absent = klass.from_h({})
      refute_predicate absent.status, :present?
      refute_predicate absent.nullable, :present?
      assert_empty absent.to_h
      assert_raises(KeyError) { klass.from_h("status" => "missing") }
    end
  end

  def test_project_format_coercer_loads_members_and_dumps_raw_values
    with_namespace do |namespace|
      calls = []
      coercer = Module.new
      namespace.const_set(:StatusCoercer, coercer)
      coercer.define_singleton_method(:coerce) do |value|
        calls << value
        enum = namespace::Schema::Props::Status
        case value
        when String
          enum.deserialize(value.downcase)
        when enum
          value.serialize
        else
          value
        end
      end
      scalar_types = {
        %w[string project-status] =>
          Schematrix::ScalarType.new(sorbet: "String", rbs: "String", coercer:),
      }
      generate_into(namespace, "enum_format", scalar_types:) do |_output|
        loaded = namespace::Schema.from_h("status" => "ACTIVE")
        assert_same namespace::Schema::Props::Status::Active, loaded.status
        assert_equal({ "status" => "active" }, loaded.to_h)
        assert_equal ["ACTIVE", loaded.status], calls
        assert_same loaded.status, namespace::Schema.from_h(loaded.to_h).status
        assert_raises(KeyError) do
          namespace::Schema.from_h("status" => "missing")
        end
      end
    end
  end

  private

  def source_hash
    {
      "status" => "active",
      "affiliation" => "employee",
      "second" => "employee",
      "statuses" => %w[employee external],
      "labels" => {
        "owner" => "external",
      },
      "rank" => 2,
    }
  end

  def with_namespace
    namespace = Module.new
    name = "EnumIntegration#{namespace.object_id}"
    Object.const_set(name, namespace)
    yield namespace
  ensure
    if name && Object.const_defined?(name, false)
      Object.send(:remove_const, name)
    end
  end

  def with_generated
    with_namespace do |namespace|
      generate_into(namespace, "enum_pipeline") do |output|
        yield namespace, output
      end
    end
  end

  def generate_into(namespace, fixture, scalar_types: {})
    Dir.mktmpdir do |output|
      generators =
        %w[
          plain_ruby
          plain_ruby_enums
          dsl_plain_ruby
          partial_plain_ruby
          auxiliary_files
        ].map do |name|
          Schematrix::GENERATORS.fetch(name).new(
            output,
            namespace.name,
            scalar_types:,
          )
        end
      Schematrix.generate(
        generators:,
        input_files: [File.join(FIXTURES_DIR, fixture, "schema.json")],
      )
      Dir["#{output}/**/*.rb"].each { |path| require path }
      yield output
    end
  end
end
