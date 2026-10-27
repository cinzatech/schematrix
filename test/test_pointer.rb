require_relative "test_helper"

class TestPointer < Minitest::Test
  # Every key spelling escapes to a token that decodes back to it.
  def test_escape_and_unescape_round_trip
    %w[
      plain
      a/b
      a~1b
      a~0b
      a%2Fb
      a%7E1b
      filter[name]
      first
      name
      名前
      @
      %
    ].each do |key|
      token = Schematrix::Pointer.escape(key)

      assert_equal key, Schematrix::Pointer.unescape(token), key
    end
  end

  def test_escaped_tokens_stay_parseable_uris
    %w[plain a/b a~1b filter[name] first name @ %].each do |key|
      uri =
        URI(
          "file:///schemas/x.json#/properties/#{Schematrix::Pointer.escape(key)}",
        )

      assert_equal key,
                   Schematrix::Pointer.unescape(uri.fragment.split("/").last),
                   key
    end
  end

  # RFC 6901 evaluation: the URI percent layer decodes before the
  # JSON pointer layer, so a hand-written %7E1 means ~1 and a
  # hand-written ~1 means /.
  def test_percent_layer_decodes_before_the_pointer_layer
    assert_equal "a/b", Schematrix::Pointer.unescape("a%7E1b")
    assert_equal "a/b", Schematrix::Pointer.unescape("a~1b")
    assert_equal "a~", Schematrix::Pointer.unescape("a%7E0")
    assert_equal "a~", Schematrix::Pointer.unescape("a~0")
  end
end
