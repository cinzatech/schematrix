# Library API

The CLI wraps one entry point. Require the gem and call
`Schematrix.generate`:

```ruby
require "schematrix"
require "schematrix/generators/base"

Schematrix.generate(
  generators: [
    Schematrix::Generators::PlainRuby.new("generated", "MyApp"),
    Schematrix::Generators::Rbs.new("sig", "MyApp"),
  ],
  input_files: ["person.schema.json"],
)
```

`Schematrix.generate` compiles every schema reachable from the inputs
and calls `write` on each generator per compiled class. It returns the
compiled records, a hash keyed by schema locator
(`file:///path/to/person.schema.json#/properties/address`) whose values
are internal `Schematrix::Schema` data objects. Treat the values as
opaque unless you are extending the tool.

## Parameters

| Parameter       | Type    | Meaning                                                                |
| --------------- | ------- | ---------------------------------------------------------------------- |
| `generators`    | array   | Generator instances, one per output format.                            |
| `input_files`   | array   | Schema document paths, JSON or YAML.                                   |
| `closed_shapes` | boolean | Absent `additionalProperties` behaves as `false`. Default `false`.     |
| `schema_dirs`   | array   | Directories remote schema URIs resolve through, in order. Default `[]`.|

The library default for `schema_dirs` is empty: unlike the CLI, the
library does not fall back to `vendor/schemas`. Pass the directories
you want.

## Errors

`generate` raises, in order:

- `Schematrix::InvalidSchemaError` when a document parses to something
  that is neither an object nor a boolean.
- `Schematrix::UnsupportedDialectError` when a `$schema` header names a
  dialect other than draft 2020-12.
- `Schematrix::UnresolvableLocatorError` when a `$ref` or `$dynamicRef`
  target cannot be found, a remote URI has no local file, or a URI
  scheme is unsupported.
- `Schematrix::OutputCollisionError` when two compiled classes, or two
  generators sharing a file extension in one directory, would write the
  same file.
- `Schematrix::CoercionConflictError` while rendering a class whose
  schema unions branches that would convert the same JSON type through
  different coercers (see [Limits](limits.md)).
- `Schematrix::CoercionHelperCollisionError` while rendering a class
  whose coerced property names fold onto the generated coercion
  helpers.

Collisions are checked for every generator and class before the first
file is written, so a failed run leaves no partial output.

## Logging

`Schematrix.logger` is `nil` by default and the pipeline runs silent.
Assign a logger to observe the run; the CLI assigns a `TTY::Logger`.
The pipeline calls `debug`, `info`, `warn`, and `fatal` on it:

```ruby
require "tty-logger"
Schematrix.logger = TTY::Logger.new
```

## Driving a generator directly

Generator instances are usable without the compiler. Each takes an
output directory and a module name:

```ruby
generator = Schematrix::Generators::PlainRuby.new("out", "MyApp")

generator.target_path(locator) # => "out/person.rb", no side effects
generator.write(locator, node) # renders, formats, writes, returns the path
```

- `locator` is the URI string of a compiled object schema.
- `node` is the `Schematrix::Schema` record for that locator.
- Pass `format: false` to skip SyntaxTree formatting and receive the
  template output as-is.
- Pass `command:` to name the regenerating command in the written
  files' banner; the CLI passes `schematrix`, the rake task
  `rake meta:generate`.
- Pass `scalar_types:` to map `[type, format]` pairs to renderings of
  the project's own, merged over the built-in table (below).
- Pass `immutable: true` to write data classes as frozen value
  objects: readers instead of accessors, a `with` copier, and value
  equality. The data generators accept it; the `dsl_` builders refuse
  it. See [Immutable classes](generated-code.md).

## Scalar types

`scalar_types` customizes how scalar slots render, per notation, and
which of them convert on load and dump:

```ruby
Schematrix::Generators::SorbetRuby.new(
  "app/generated",
  "Billing",
  scalar_types: {
    ["string", "money"] => Schematrix::ScalarType.new(
      sorbet: "Money",
      rbs: "Money",
      coercer: Money
    ),
    ["integer", "id"] => Schematrix::ScalarType.new(
      sorbet: "Id",
      rbs: "Id"
    )
  }
)
```

The keys are `[type, format]` pairs; a lookup tries the exact pair,
then the bare type, so a format with no entry renders as its bare
type. `Schematrix::ScalarType` carries the Sorbet spelling, the RBS
spelling, and an optional coercer: any named module answering
`coerce(value)`. A coercing slot follows the same rule the
nested-class slots follow: a document value loads through
`coercer.coerce`, an instance dumps through it, and anything else
passes through. That conversion runs at every position the type
algebra renders the formatted type: scalar properties, array elements
and tuple positions, map and catch-all values, and union branches.
The built-in table maps the standard
formats this way (`date` to `Date`, `date-time` to `Time`) and emits
the converter into the generated file; a project coercer is referenced
by its name and required by the generate script, as any class it names
is. A union whose branches convert the same JSON type through
different coercers has no correct converter and fails the run with
`CoercionConflictError` (see [Limits](limits.md)).

A coercer must be a named module (or class) answering `coerce`: an
anonymous module, a nameless value, or a missing method raises
`ArgumentError` at generator construction, before any file is
written.

Eight generator classes exist: `PlainRuby`, `SorbetRuby`, `Rbi`, and
`Rbs` for the data classes, plus `DslPlainRuby`, `DslSorbetRuby`,
`DslRbi`, and `DslRbs` for the instance builders. They share the
rendering described in [Generators](generators.md); the builders place
every class under a `Dsl` module level, so a data generator and a DSL
generator can write to one directory.

## The generated loading model

`require "schematrix"` also loads `Schematrix::Meta::Schema` under
`lib/schematrix/meta/`. That class is schematrix's own loading model for
schema documents, generated by `rake meta:generate` from the vendored
2020-12 metaschema. It is an implementation detail of the compiler, not
a public surface. It is excluded from the API reference on purpose.
