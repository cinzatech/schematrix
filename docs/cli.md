# Command line reference

```text
Usage: schematrix [OPTIONS] INPUT [INPUT...]

Generate code matching a JSON Schema

Options:
      --closed-shapes      Treat absent additionalProperties as false: closed
                           classes with no catch-all, instead of the spec
                           default
  -g, --generators list    Output generators to use, e.g.: plain_ruby,
                           dsl_plain_ruby
  -h, --help               Print usage
      --immutable          Generate data classes as frozen value objects:
                           readers, a with copier, and value equality; data
                           generators only
  -m, --module string      Module where the output code will be placed
  -o, --output string      Directory where the output will be written
      --schema-dir string  Directory where remote schema URIs resolve to local
                           files; may be given multiple times, defaults to
                           vendor/schemas
  -v, --verbose            Each additional occurrence lowers logger level,
                           -vvv for the minimum

Examples:
  Produce plain Ruby code for the given schema
    $ schematrix -g plain_ruby -m MyModule -o /output/dir my-json-schema.json
```

## Inputs

`INPUT` names one or more schema documents. Each one is a compilation
root: the compiler walks every schema node reachable from it, following
`$ref` edges, and generates a class per object schema it finds. JSON and
YAML both load.

Two input files may not share a basename (`a.json` and `a.yaml` fold to
the same class name). The run refuses with `OutputCollisionError` before
any file is written. See [Names and files](naming.md).

## Options

### `-g, --generators`

Required. One or more generator names, given as repeated flags or as a
comma-separated list. The names are `plain_ruby`, `sorbet_ruby`, `rbi`,
`rbs`, the `dsl_` prefixed builders of each (`dsl_plain_ruby`,
`dsl_sorbet_ruby`, `dsl_rbi`, `dsl_rbs`), and `coercion_helper`, the
run-once auxiliary generator behind the shared coercion module (see
[generators](generators.md)). An unknown name stops the run
with a fatal log message and exit status 1.

```sh
schematrix -g plain_ruby,rbs -m MyApp schema.json
schematrix -g plain_ruby -g rbs -m MyApp schema.json
```

### `-m, --module`

Required. The namespace the generated code is placed in. Dotted names
nest modules:

```sh
schematrix -g plain_ruby -m "Acme::Contracts" schema.json
```

### `-o, --output`

Optional. The output directory, created when missing. The flag pairs
with `-g`:

- No `-o`: every generator writes to `generated/`.
- One `-o`: every generator writes to that directory. Generators with
  different file extensions (`.rb`, `.rbs`, `.rbi`) share a directory
  without colliding.
- One `-o` per `-g`: each generator writes to its own directory, paired
  in flag order.

A count of output directories that matches neither 1 nor the generator
count stops the run with exit status 1.

```sh
# Ruby code in generated/, RBS in sig/
schematrix -g plain_ruby -o generated -g rbs -o sig schema.json

# Both formats in generated/
schematrix -g plain_ruby,rbs -o generated schema.json
```

Two generators that share a file extension and a directory collide and
stop the run with `OutputCollisionError`.

### `--closed-shapes`

The JSON Schema default for an absent `additionalProperties` is "extra
keys accepted". The flag switches that default to "closed": generated
classes carry no catch-all accessors and drop unknown keys on load.
Explicit `additionalProperties` in the document always wins over the
flag. See [Schema features](schema-features.md).

### `--immutable`

Generates data classes as frozen value objects: readers instead of
accessors, frozen instances, a `with` copier, and value equality. The
flag applies to every data generator of the run; the `dsl_` builders
are unaffected, since a builder is mutable by construction. See
[Immutable classes](generated-code.md).

### `--schema-dir`

Remote schema URIs (`http`/`https` `$ref` targets) never touch the
network. They resolve to files under the given directories, which mirror
the URI as `host/path`. The flag may repeat; directories are searched in
order, and the first match wins. With no flag the default is
`vendor/schemas`; an explicit `--schema-dir` replaces the default
entirely. See [Schema features](schema-features.md) for the layout.

### `-v, --verbose`

Sets the log level of the built-in [TTY::Logger](https://github.com/piotrmurach/tty-logger)
output on stderr:

| Occurrences | Level |
| ----------- | ----- |
| none        | warn  |
| `-v`        | info  |
| `-vv`       | debug |
| `-vvv`      | debug |

Debug output logs CLI arguments, each written file, ignored keywords,
and `$dynamicRef` fallbacks.

### `-h, --help`

Prints the usage text above.

## Exit behavior

The process exits 0 after a successful run. It exits 1 after a usage
error, an unknown generator, an output count mismatch, a schema that
cannot load or compile, or an output collision. The failure reason is
logged with level `fatal`.

## Library equivalent

The CLI is a thin wrapper over `Schematrix.generate`. See
[Library API](library-api.md).
