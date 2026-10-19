require "minitest/autorun"
require "uri"
require_relative "../lib/schematrix"
require_relative "../lib/schematrix/generators/base"

module SchematrixTestHelper
  MODULE_NAME = "M"
  FIXTURES_DIR = File.join(__dir__, "fixtures")

  # One source of truth for generator file extensions: the registry
  GENERATOR_EXTENSIONS =
    Schematrix::GENERATORS.transform_values(&:file_extension).freeze

  private

  # Fixtures are hand-authored target state (hard rule, D15 in the
  # worklog): never write the expected files from generator output, and
  # never add a mode here that does.
  def assert_fixture(
    fixture_name,
    generator_name,
    path: "",
    closed_shapes: false,
    schema_dirs: [],
    locator: nil
  )
    actual =
      generate_fixture(
        fixture_name,
        generator_name,
        path:,
        closed_shapes:,
        schema_dirs:,
        locator:,
      )

    expected_file = expected_path(fixture_name, generator_name, path)

    expected = File.read(expected_file)

    assert_equal expected,
                 actual,
                 "Output mismatch for #{generator_name} (path: #{path.inspect})"
  end

  def generate_fixture(
    fixture_name,
    generator_name,
    path: "",
    closed_shapes: false,
    schema_dirs: [],
    locator: nil
  )
    schema_file = File.join(FIXTURES_DIR, fixture_name, "schema.json")
    objects =
      Schematrix::Compiler.new(
        store: Schematrix::DocumentStore.new(schema_dirs:),
        closed_shapes:,
      ).compile([schema_file])
    uri = URI(locator || fixture_locator(schema_file, path))
    node = objects.fetch(uri.to_s)

    generator =
      Schematrix::GENERATORS[generator_name].new(
        "/tmp",
        MODULE_NAME,
        format: true,
      )
    generator.transform(uri, generator.class_name_from_path(uri), node)
  end

  # Maps a test-friendly path like 'l1/l2' or 'Address' to the locator of
  # the corresponding schema node. Names found under $defs resolve there,
  # anything else is a chain of property names.
  def fixture_locator(schema_file, path)
    fragment =
      if path.empty?
        "/"
      elsif defs_entry?(schema_file, path.split("/").first)
        "/$defs/#{path}"
      else
        "/#{
          path.split("/").map { |segment| "properties/#{segment}" }.join("/")
        }"
      end

    "file://#{File.expand_path(schema_file)}##{fragment}"
  end

  def defs_entry?(schema_file, name)
    schema = YAML.safe_load_file(schema_file)
    !schema.dig("$defs", name).nil?
  end

  # Compiles a fixture schema and returns the whole objects hash, for
  # assertions about which classes exist (or do not).
  def compile_fixture(fixture_name, closed_shapes: false, schema_dirs: [])
    schema_file = File.join(FIXTURES_DIR, fixture_name, "schema.json")
    Schematrix::Compiler.new(
      store: Schematrix::DocumentStore.new(schema_dirs:),
      closed_shapes:,
    ).compile([schema_file])
  end

  def expected_path(fixture_name, generator_name, path)
    ext = GENERATOR_EXTENSIONS.fetch(generator_name)
    if path.empty?
      filename = "#{generator_name}#{ext}"
    else
      prefix = path.tr("/", "_")
      filename = "#{prefix}.#{generator_name}#{ext}"
    end
    File.join(FIXTURES_DIR, fixture_name, filename)
  end
end
