require_relative "test_helper"
require "tmpdir"

class TestGeneratorBanner < Minitest::Test
  def test_multiline_commands_remain_comments
    ["\n", "\r\n", "\r"].each do |newline|
      Dir.mktmpdir do |dir|
        generator =
          Schematrix::Generators::PlainRuby.new(
            dir,
            "BannerRegression",
            command: "generate#{newline}raise 'injected'",
          )
        code =
          generator.send(
            :with_banner,
            "module BannerRegression; end\n",
            "Schema",
          )
        assert(code.lines.grep(/raise/).all? { |line| line.start_with?("# ") })
        Module.new.module_eval(code)
      end
    end
  end
end
