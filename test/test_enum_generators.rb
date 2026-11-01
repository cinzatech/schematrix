require_relative "test_helper"
require "tmpdir"

class TestEnumGenerators < Minitest::Test
  FLAVORS = %w[plain_ruby sorbet_ruby rbi rbs].freeze

  STRING_GOLDENS = {
    "plain_ruby" => <<~RUBY,
      module M
        class Affiliation
          def initialize(value)
            @value = value.freeze
            freeze
          end
          private_class_method :new

          def serialize
            @value
          end

          Employee = new("employee")
          External = new("external")

          def self.values
            [Employee, External]
          end

          def self.deserialize(value)
            { "employee" => Employee, "external" => External }.fetch(value)
          end

          def self.coerce(value)
            case value
            when ::String
              deserialize(value)
            when ::M::Affiliation
              value.serialize
            else
              value
            end
          end
        end
      end
    RUBY
    "sorbet_ruby" => <<~RUBY,
      # typed: strict

      module M
        class Affiliation < ::T::Enum
          extend ::T::Sig
          enums do
            Employee = new("employee")
            External = new("external")
          end

          sig { params(value: ::T.anything).returns(::T.anything) }
          def self.coerce(value)
            case value
            when ::String
              deserialize(value)
            when ::M::Affiliation
              value.serialize
            else
              value
            end
          end
        end
      end
    RUBY
    "rbi" => <<~RUBY,
      # typed: strict

      module M
        class Affiliation < ::T::Enum
          extend ::T::Sig
          enums do
            Employee = new
            External = new
          end

          sig { params(value: ::T.anything).returns(::T.anything) }
          def self.coerce(value)
          end
        end
      end
    RUBY
    "rbs" => <<~RBS,
      module M
        class Affiliation
          Employee: Affiliation
          External: Affiliation

          def self.values: -> Array[Affiliation]
          def self.deserialize: (String) -> Affiliation
          def self.coerce: (top) -> top
          def serialize: -> String
        end
      end
    RBS
  }.freeze

  INTEGER_GOLDENS = {
    "plain_ruby" => <<~RUBY,
      module M
        class Affiliation
          def initialize(value)
            @value = value.freeze
            freeze
          end
          private_class_method :new

          def serialize
            @value
          end

          N1 = new(1)
          N2 = new(2)

          def self.values
            [N1, N2]
          end

          def self.deserialize(value)
            { 1 => N1, 2 => N2 }.fetch(value)
          end

          def self.coerce(value)
            case value
            when ::Integer
              deserialize(value)
            when ::M::Affiliation
              value.serialize
            else
              value
            end
          end
        end
      end
    RUBY
    "sorbet_ruby" => <<~RUBY,
      # typed: strict

      module M
        class Affiliation < ::T::Enum
          extend ::T::Sig
          enums do
            N1 = new(1)
            N2 = new(2)
          end

          sig { params(value: ::T.anything).returns(::T.anything) }
          def self.coerce(value)
            case value
            when ::Integer
              deserialize(value)
            when ::M::Affiliation
              value.serialize
            else
              value
            end
          end
        end
      end
    RUBY
    "rbi" => <<~RUBY,
      # typed: strict

      module M
        class Affiliation < ::T::Enum
          extend ::T::Sig
          enums do
            N1 = new
            N2 = new
          end

          sig { params(value: ::T.anything).returns(::T.anything) }
          def self.coerce(value)
          end
        end
      end
    RUBY
    "rbs" => <<~RBS,
      module M
        class Affiliation
          N1: Affiliation
          N2: Affiliation

          def self.values: -> Array[Affiliation]
          def self.deserialize: (Integer) -> Affiliation
          def self.coerce: (top) -> top
          def serialize: -> Integer
        end
      end
    RBS
  }.freeze

  def test_root_goldens
    [
      [%w[employee external], STRING_GOLDENS],
      [[1, 2], INTEGER_GOLDENS],
    ].each do |values, goldens|
      compile({ "enum" => values }, "affiliation") do |objects|
        locator, node = objects.first
        FLAVORS.each do |flavor|
          assert_equal goldens.fetch(flavor), render(flavor, locator, node)
        end
      end
    end
  end

  def test_nested_declarations
    compile(
      {
        "type" => "object",
        "properties" => {
          "status" => {
            "enum" => ["active", nil, "inactive", "active"],
          },
          "affiliation" => {
            "$ref" => "#/$defs/affiliation",
          },
          "second" => {
            "$ref" => "#/$defs/affiliation",
          },
        },
        "$defs" => {
          "affiliation" => {
            "enum" => %w[employee external],
          },
        },
      },
      "person",
    ) do |objects|
      nodes = objects.select { |_locator, node| node.enum_class? }
      assert_equal 2, nodes.size
      nodes.each do |locator, node|
        FLAVORS.each do |flavor|
          source = render(flavor, locator, node)
          container, leaf =
            locator.include?("$defs") ? %w[Defs Affiliation] : %w[Props Status]
          declaration =
            "class Person\n    module #{container}\n      class #{leaf}"
          assert_includes source, declaration
          if %w[rbi sorbet_ruby].include?(flavor)
            assert_equal 1, source.scan("< ::T::Enum").size
          end
          refute_includes source, "nil)"
          refute_includes source, "Maybe"
          refute_includes source, "Partial"
        end
      end
    end
  end

  def test_folding_and_collisions
    base = Schematrix::Generators::Templates::EnumBase
    expected = [
      %w[InProgress in.progress],
      %w[N2fa 2fa],
      ["Empty", ""],
      %w[N40 @],
    ]
    assert_equal expected,
                 base.fold_members(["in.progress", "2fa", "", "@", "2fa", nil])
    error =
      assert_raises(Schematrix::OutputCollisionError) do
        base.fold_members(%w[in-progress in_progress])
      end
    assert_includes error.message, '"in-progress"'
    assert_includes error.message, '"in_progress"'
    compile({ "enum" => %w[a.b a/b] }, "affiliation") do |objects|
      locator, node = objects.first
      FLAVORS.each do |flavor|
        assert_raises(Schematrix::OutputCollisionError) do
          render(flavor, locator, node)
        end
      end
    end
  end

  def test_sorbet_rejects_a_member_named_after_its_class
    compile({ "enum" => %w[affiliation other] }, "affiliation") do |objects|
      locator, node = objects.first
      %w[sorbet_ruby rbi].each do |flavor|
        error =
          assert_raises(Schematrix::OutputCollisionError) do
            render(flavor, locator, node)
          end
        assert_includes error.message, "affiliation"
        assert_includes error.message, "Sorbet"
      end
      assert_includes render("plain_ruby", locator, node), "Affiliation = new"
      assert_includes render("rbs", locator, node), "Affiliation: Affiliation"
    end
  end

  def test_registry_and_maybe
    writers =
      Schematrix::GENERATORS.select { |_name, klass| klass.enum_generator? }
    assert_equal FLAVORS.map { |name| "#{name}_enums" }.sort, writers.keys.sort
    writers.each_value do |klass|
      refute_predicate klass.new("/tmp", "M", optionals: :maybe), :maybe_needed?
      assert_same klass.erb(klass.enum_template_name),
                  klass.erb(klass.enum_template_name)
      refute_same klass.erb, klass.erb(klass.enum_template_name)
    end
  end

  def test_plain_runtime
    [
      %w[employee external],
      [1, 2],
      ["", "quoted\"\nvalue"],
      %w[String Integer Affiliation T],
    ].each do |values|
      compile({ "enum" => values }, "affiliation") do |objects|
        locator, node = objects.first
        namespace = Module.new
        namespace_name = "EnumRuntime#{namespace.object_id}"
        Object.const_set(namespace_name, namespace)
        Object.class_eval(
          render("plain_ruby", locator, node, module_name: namespace_name),
        )
        klass = namespace.const_get(:Affiliation)
        assert_equal values, klass.values.map(&:serialize)
        members = klass.values
        members.each do |member|
          assert_predicate member, :frozen?
          assert_predicate member.serialize, :frozen?
          assert_same member, klass.deserialize(member.serialize)
          assert_same member, klass.coerce(member.serialize)
          assert_equal member.serialize, klass.coerce(member)
        end
        refute_equal klass.values.first, klass.values.last
        assert_raises(NoMethodError) { klass.new(values.first) }
        assert_raises(KeyError) { klass.deserialize("missing") }
        assert_raises(KeyError) do
          klass.coerce(values.first.is_a?(Integer) ? 99 : "missing")
        end
        [nil, false, Object.new, []].each do |value|
          assert value.equal?(klass.coerce(value))
        end
        klass.values.clear
        assert_equal values.size, klass.values.size
      ensure
        Object.send(:remove_const, namespace_name) if namespace_name
      end
    end
  end

  private

  def render(flavor, locator, node, module_name: "M")
    generator =
      Schematrix::GENERATORS.fetch("#{flavor}_enums").new("/tmp", module_name)
    uri = URI(locator)
    generator.transform(uri, generator.class_name_from_path(uri), node)
  end

  def compile(schema, name)
    Dir.mktmpdir do |directory|
      path = File.join(directory, "#{name}.json")
      File.write(path, JSON.generate(schema))
      yield Schematrix::Compiler.new(enums_classes: true).compile([path])
    end
  end
end
