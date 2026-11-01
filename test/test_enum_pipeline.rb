require_relative "test_helper"
require "tmpdir"

class TestEnumPipeline < Minitest::Test
  def test_shared_directory_partitions_objects_and_enums
    with_schema do |path, output|
      generators =
        %w[plain_ruby plain_ruby_enums].map do |name|
          Schematrix::GENERATORS.fetch(name).new(output, "M")
        end
      records = Schematrix.generate(generators:, input_files: [path])
      assert_equal 2, records.size
      assert_equal %w[person.rb person/props/status.rb], files(output)
      assert_includes File.read(File.join(output, "person.rb")),
                      "::M::Person::Props::Status.coerce(value)"
      assert_includes File.read(File.join(output, "person/props/status.rb")),
                      "Active = new"
    end
  end

  def test_explicit_unions_still_writes_enums_without_using_them
    with_schema do |path, output|
      generators = [
        Schematrix::Generators::Rbs.new(output, "M", enums: :unions),
        Schematrix::Generators::PlainRubyEnums.new(output, "M"),
      ]
      Schematrix.generate(generators:, input_files: [path])
      assert_equal %w[person.rbs person/props/status.rb], files(output)
      assert_includes File.read(File.join(output, "person.rbs")),
                      '("active" | "inactive")?'
    end
  end

  def test_usage_without_enum_writers_warns_and_skips_enum_locators
    with_schema do |path, output|
      logger = Object.new
      warnings = []
      logger.define_singleton_method(:warn) { |message| warnings << message }
      logger.define_singleton_method(:info) { |_message| nil }
      logger.define_singleton_method(:debug) { |*_args| nil }
      previous = Schematrix.logger
      Schematrix.logger = logger
      generators = [
        Schematrix::Generators::DslPlainRuby.new(output, "M", enums: :classes),
        Schematrix::Generators::PartialPlainRuby.new(output, "M"),
      ]
      Schematrix.generate(generators:, input_files: [path])
      assert_equal %w[dsl/person.rb maybe.rb partial/person.rb], files(output)
      assert_equal 1, warnings.size
      assert_includes warnings.first, "*_enums"
    ensure
      Schematrix.logger = previous
    end
  end

  def test_enum_only_writer_does_not_write_data_classes_or_maybe
    with_schema do |path, output|
      generator =
        Schematrix::Generators::PlainRubyEnums.new(
          output,
          "M",
          optionals: :maybe,
        )
      Schematrix.generate(generators: [generator], input_files: [path])
      assert_equal ["person/props/status.rb"], files(output)
    end
  end

  def test_two_enum_writers_with_same_extension_collide_before_writing
    with_schema do |path, output|
      generators = [
        Schematrix::Generators::PlainRubyEnums.new(output, "M"),
        Schematrix::Generators::SorbetRubyEnums.new(output, "M"),
      ]
      assert_raises(Schematrix::OutputCollisionError) do
        Schematrix.generate(generators:, input_files: [path])
      end
      refute Dir.exist?(output)
    end
  end

  def test_member_collisions_fail_before_any_file_is_written
    [
      ["plain_ruby_enums", %w[in-progress in_progress]],
      ["sorbet_ruby_enums", %w[status other]],
    ].each do |writer, members|
      with_schema do |path, output|
        document = JSON.parse(File.read(path))
        document["properties"]["status"]["enum"] = members
        File.write(path, JSON.generate(document))
        generators = [
          Schematrix::Generators::PlainRuby.new(output, "M"),
          Schematrix::GENERATORS.fetch(writer).new(output, "M"),
        ]
        assert_raises(Schematrix::OutputCollisionError) do
          Schematrix.generate(generators:, input_files: [path])
        end
        refute Dir.exist?(output)
      end
    end
  end

  def test_default_without_writer_does_not_register_enum_classes
    with_schema do |path, output|
      generator = Schematrix::Generators::PlainRuby.new(output, "M")
      objects =
        Schematrix.generate(generators: [generator], input_files: [path])
      assert_equal 1, objects.size
      assert_equal ["person.rb"], files(output)
      refute_includes File.read(File.join(output, "person.rb")), "coerce_status"
    end
  end

  private

  def files(output)
    Dir
      .glob("#{output}/**/*")
      .select { |path| File.file?(path) }
      .map { |path| path.delete_prefix("#{output}/") }
      .sort
  end

  def with_schema
    Dir.mktmpdir do |dir|
      path = File.join(dir, "person.json")
      File.write(
        path,
        JSON.generate(
          {
            "type" => "object",
            "additionalProperties" => false,
            "properties" => {
              "status" => {
                "enum" => %w[active inactive],
              },
            },
          },
        ),
      )
      yield path, File.join(dir, "out")
    end
  end
end
