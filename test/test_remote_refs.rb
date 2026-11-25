require_relative "test_helper"
require "tmpdir"

class TestRemoteRefs < Minitest::Test
  include SchematrixTestHelper

  SCHEMA_DIRS = [
    File.join(SchematrixTestHelper::FIXTURES_DIR, "remote_ref", "schemas"),
  ].freeze

  def test_root_generation_through_remote_refs
    assert_fixture("remote_ref", "plain_ruby", schema_dirs: SCHEMA_DIRS)
    assert_fixture("remote_ref", "rbs", schema_dirs: SCHEMA_DIRS)
  end

  def test_remote_object_generates_its_own_class
    locator = "https://example.com/schemas/address#/"
    assert_fixture(
      "remote_ref",
      "plain_ruby",
      path: "address",
      locator:,
      schema_dirs: SCHEMA_DIRS,
    )
    assert_fixture(
      "remote_ref",
      "rbs",
      path: "address",
      locator:,
      schema_dirs: SCHEMA_DIRS,
    )
  end

  def test_all_remote_targets_are_compiled
    objects = compile_remote_ref

    expected = %w[
      https://example.com/schemas/address#/
      https://example.com/schemas/address#/properties/zip
      https://other.example/postal_address#/
    ]
    assert_equal expected, objects.keys.grep(%r{\Ahttps?://}).sort
  end

  def test_remote_ref_without_schema_dirs_raises
    error =
      assert_raises(Schematrix::UnresolvableLocatorError) do
        Schematrix::Compiler.new.compile([remote_ref_schema_file])
      end

    assert_match(/no schema directory configured/, error.message)
  end

  def test_unknown_remote_uri_lists_candidates
    error =
      assert_raises(Schematrix::UnresolvableLocatorError) do
        Schematrix::Compiler.new(
          store:
            Schematrix::DocumentStore.new(
              schema_dirs: [
                File.join(SchematrixTestHelper::FIXTURES_DIR, "remote_ref"),
              ],
            ),
        ).compile([remote_ref_schema_file])
      end

    assert_match(%r{example\.com/schemas/address}, error.message)
  end

  def test_input_file_that_is_a_ref_target_compiles_once
    with_shop_schemas do |dir, order, money, _|
      [[order, money], [money, order]].each do |inputs|
        objects = compile_inputs(dir, inputs)

        assert_equal [root_locator(money), root_locator(order)],
                     objects.keys.sort
      end
    end
  end

  def test_input_file_with_a_ref_into_its_defs_compiles_once
    with_shop_schemas do |dir, _, _, price|
      cart =
        write_json(
          File.join(dir, "cart.json"),
          "type" => "object",
          "properties" => {
            "currency" => {
              "$ref" => "https://example.com/schemas/price#/$defs/currency",
            },
          },
        )
      currency = "#{root_locator(price).chomp("/")}/$defs/currency"

      [[cart, price], [price, cart]].each do |inputs|
        objects = compile_inputs(dir, inputs)

        assert_includes objects.keys, currency
        assert_empty objects.keys.grep(%r{\Ahttps?://})
      end
    end
  end

  def test_input_file_that_is_a_ref_target_generates_one_class
    with_shop_schemas do |dir, order, money, _|
      output = File.join(dir, "out")

      Schematrix.generate(
        generators: [Schematrix::Generators::PlainRuby.new(output, "Shop")],
        input_files: [order, money],
        schema_dirs: [File.join(dir, "schemas")],
      )

      assert_equal %w[money.rb order.rb], Dir.children(output).sort
    end
  end

  private

  def with_shop_schemas
    Dir.mktmpdir do |dir|
      schemas = File.join(dir, "schemas", "example.com", "schemas")
      money =
        write_json(
          File.join(schemas, "money.json"),
          "$id" => "https://example.com/schemas/money",
          "type" => "object",
          "properties" => {
            "cents" => {
              "type" => "integer",
            },
          },
        )
      order =
        write_json(
          File.join(schemas, "order.json"),
          "$id" => "https://example.com/schemas/order",
          "type" => "object",
          "properties" => {
            "total" => {
              "$ref" => "https://example.com/schemas/money",
            },
          },
        )
      price =
        write_json(
          File.join(schemas, "price.json"),
          "$id" => "https://example.com/schemas/price",
          "type" => "object",
          "properties" => {
            "amount" => {
              "type" => "number",
            },
          },
          "$defs" => {
            "currency" => {
              "type" => "object",
              "properties" => {
                "code" => {
                  "type" => "string",
                },
              },
            },
          },
        )
      yield dir, order, money, price
    end
  end

  def write_json(path, document)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, JSON.generate(document))
    path
  end

  def compile_inputs(dir, inputs)
    Schematrix::Compiler.new(
      store:
        Schematrix::DocumentStore.new(schema_dirs: [File.join(dir, "schemas")]),
    ).compile(inputs)
  end

  def root_locator(path)
    "file://#{URI::RFC2396_PARSER.escape(File.expand_path(path))}#/"
  end

  def compile_remote_ref
    Schematrix::Compiler.new(
      store: Schematrix::DocumentStore.new(schema_dirs: SCHEMA_DIRS),
    ).compile([remote_ref_schema_file])
  end

  def remote_ref_schema_file
    File.join(SchematrixTestHelper::FIXTURES_DIR, "remote_ref", "schema.json")
  end
end
