require_relative "test_helper"

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

  private

  def compile_remote_ref
    Schematrix::Compiler.new(
      store: Schematrix::DocumentStore.new(schema_dirs: SCHEMA_DIRS),
    ).compile([remote_ref_schema_file])
  end

  def remote_ref_schema_file
    File.join(SchematrixTestHelper::FIXTURES_DIR, "remote_ref", "schema.json")
  end
end
