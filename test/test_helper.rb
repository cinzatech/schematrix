require 'minitest/autorun'
require 'json'
require_relative '../lib/schematrix'

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
    schema = JSON.parse(File.read(File.join(FIXTURES_DIR, fixture_name, 'schema.json')))
    objects = Schematrix::Visitor.new.compile(schema)
    node = objects[path]

    generator = Schematrix::GENERATORS[generator_name].new(
      '/tmp', MODULE_NAME, schema['title'], format: true
    )
    actual = generator.transform(path, node)

    expected_file = expected_path(fixture_name, generator_name, path)
    expected = File.read(expected_file)

    assert_equal expected, actual,
                 "Output mismatch for #{generator_name} (path: #{path.inspect})"
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
