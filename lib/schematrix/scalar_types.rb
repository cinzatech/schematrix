require_relative "coercers"
require_relative "visitor"

module Schematrix
  # How a [type, format] pair renders in each notation, and the module
  # that converts its values on load and dump when the Ruby type is
  # not the JSON one. A nil coercer means the value passes through.
  ScalarType =
    Data.define(:sorbet, :rbs, :coercer) do
      def initialize(sorbet:, rbs:, coercer: nil) = super

      def coerces? = !coercer.nil?
    end

  # The rendering of every JSON Schema scalar type and of the standard
  # formats, keyed by [type, format]; a nil format names the bare
  # type. A format with no entry renders as its bare type, so custom
  # annotation formats change nothing until the project maps them
  # through a generator's `scalar_types:` option, which merges over
  # this table.
  BUILTIN_SCALAR_TYPES = {
    [TYPE_STRING, nil] => ScalarType.new(sorbet: "String", rbs: "String"),
    [TYPE_INTEGER, nil] => ScalarType.new(sorbet: "Integer", rbs: "Integer"),
    [TYPE_NUMBER, nil] => ScalarType.new(sorbet: "Numeric", rbs: "Numeric"),
    [TYPE_BOOLEAN, nil] => ScalarType.new(sorbet: "T::Boolean", rbs: "bool"),
    [TYPE_NULL, nil] => ScalarType.new(sorbet: "NilClass", rbs: "nil"),
    [TYPE_BOTTOM, nil] => ScalarType.new(sorbet: "T.noreturn", rbs: "top"),
    [TYPE_STRING, "date"] =>
      ScalarType.new(sorbet: "Date", rbs: "Date", coercer: Coercers::Date),
    [TYPE_STRING, "date-time"] =>
      ScalarType.new(sorbet: "Time", rbs: "Time", coercer: Coercers::DateTime),
  }.freeze
end
