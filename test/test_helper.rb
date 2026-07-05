require 'minitest/autorun'
require 'uri'
require_relative '../lib/schematrix'
require_relative '../lib/schematrix/generators/base'

module SchematrixTestHelper
  MODULE_NAME = 'M'
  FIXTURES_DIR = File.join(__dir__, 'fixtures')

  GENERATOR_EXTENSIONS = {
    'plain_ruby' => '.rb',
    'sorbet_ruby' => '.rb',
    'rbs' => '.rbs',
    'rbi' => '.rbi'
  }.freeze

  private

  def assert_fixture(fixture_name, generator_name, path: '')
    actual = generate_fixture(fixture_name, generator_name, path)

    expected_file = expected_path(fixture_name, generator_name, path)
    expected = File.read(expected_file)

    assert_equal expected, actual,
                 "Output mismatch for #{generator_name} (path: #{path.inspect})"
  end

  def generate_fixture(fixture_name, generator_name, path)
    schema_file = File.join(FIXTURES_DIR, fixture_name, 'schema.json')
    objects = Schematrix::Compiler.new.compile([schema_file])
    locator = URI(fixture_locator(schema_file, path))
    node = objects.fetch(locator.to_s)

    generator = Schematrix::GENERATORS[generator_name].new(
      '/tmp', MODULE_NAME, format: true
    )
    generator.transform(locator, generator.class_name_from_path(locator), node)
  end

  # Maps a test-friendly path like 'l1/l2' or 'Address' to the locator of
  # the corresponding schema node. Names found under $defs resolve there,
  # anything else is a chain of property names.
  def fixture_locator(schema_file, path)
    fragment =
      if path.empty?
        '/'
      elsif defs_entry?(schema_file, path.split('/').first)
        "/$defs/#{path}"
      else
        "/#{path.split('/').map { |segment| "properties/#{segment}" }.join('/')}"
      end

    "file://#{File.expand_path(schema_file)}##{fragment}"
  end

  def defs_entry?(schema_file, name)
    schema = YAML.safe_load(File.read(schema_file))
    !schema.dig('$defs', name).nil?
  end

  def expected_path(fixture_name, generator_name, path)
    ext = GENERATOR_EXTENSIONS.fetch(generator_name)
    if path.empty?
      filename = "#{generator_name}#{ext}"
    else
      prefix = path.tr('/', '_')
      filename = "#{prefix}.#{generator_name}#{ext}"
    end
    File.join(FIXTURES_DIR, fixture_name, filename)
  end
end
