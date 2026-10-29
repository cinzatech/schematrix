#!/usr/bin/env ruby
# frozen_string_literal: true

# Profiles the library itself with stackprof by repeatedly running every
# fixture schema through the compiler and all generators. No test framework
# involved, so speedscope's left-heavy view groups by library code paths.
#
# Usage:
#   ruby profile_tests.rb [output.json] [iterations]
#
# View the result at https://www.speedscope.app or with `npx speedscope`.

# Load stackprof from system gems *before* activating the bundle, since it
# is intentionally not part of the project's Gemfile.
require "stackprof"
require "json"

# Now restrict the load path to the project's locked dependencies.
require "bundler/setup"

# Converts a raw stackprof dump to the speedscope file format. stackprof
# stores raw samples root-to-leaf, which is the order speedscope expects.
# The SIGPROF timer cannot honor intervals below the kernel tick, so the
# interval is kept at the 1ms default and weights scale by it; relative
# shares are unaffected.
def speedscope_document(results)
  keys = results[:frames].keys.sort
  index_of = keys.each_with_index.to_h
  frames = keys.map { |id| { "name" => results[:frames][id][:name] } }

  samples = []
  weights = []
  raw = results[:raw]
  i = 0
  while i < raw.size
    depth = raw[i]
    samples << raw[i + 1, depth].map { |id| index_of[id] }
    weights << (raw[i + 1 + depth] * results[:interval])
    i += depth + 2
  end

  {
    "$schema" => "https://www.speedscope.app/file-format-schema.json",
    "shared" => {
      "frames" => frames,
    },
    "profiles" => [
      {
        "type" => "sampled",
        "name" => "schematrix fixtures, #{results[:mode]} mode",
        "unit" => "microseconds",
        "startValue" => 0,
        "endValue" => weights.sum,
        "samples" => samples,
        "weights" => weights,
      },
    ],
    "activeProfileIndex" => 0,
  }
end

$LOAD_PATH.unshift File.expand_path("lib", __dir__)

require "schematrix"
require "schematrix/generators"

output =
  (
    if ARGV.first&.end_with?(".json")
      ARGV.shift
    else
      "fixtures_profile.speedscope.json"
    end
  )
iterations = Integer(ARGV.shift || 20)

schemas = Dir[File.expand_path("../test/fixtures/*/schema.json", __dir__)]
abort "No fixture schemas found" if schemas.empty?

errors = Hash.new(0)

# Everything up to here (requires, globbing) stays out of the profile.
StackProf.start(mode: :cpu, raw: true, interval: 1_000)

iterations.times do
  schemas.each do |schema_file|
    objects = Schematrix::Compiler.new.compile([schema_file])

    objects.each do |locator, node|
      Schematrix::GENERATORS.each_value do |generator_class|
        generator = generator_class.new("/tmp", "M", format: false)
        uri = URI(locator)
        generator.transform(uri, generator.class_name_from_path(uri), node)
      rescue StandardError => e
        errors["#{File.basename(File.dirname(schema_file))}: #{e.class}"] += 1
      end
    end
  rescue StandardError => e
    key = "#{File.basename(File.dirname(schema_file))} (compile): #{e.class}"
    errors[key] += 1
  end
end

StackProf.stop
File.write(output, JSON.generate(speedscope_document(StackProf.results)))

puts "#{iterations} iterations over #{schemas.size} schemas"
if errors.any?
  errors.each { |what, count| warn "  skipped #{what} x#{count / iterations}" }
end
puts "Profile written to #{output} (speedscope format, cpu mode)"
