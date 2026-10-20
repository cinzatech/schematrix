# Schematrix user manual

`schematrix` reads JSON Schema documents and writes Ruby classes with type
signatures. It runs as a CLI (`schematrix`) and as a library
(`Schematrix.generate`).

This manual covers everything the tool does. The README gives the short
version; the API pages under `Schematrix` in this reference document every
public class and method.

## How a run works

1. You pass one or more schema documents (JSON or YAML) and pick one or
   more generators.
2. The compiler loads each document, checks its `$schema` dialect, and
   walks every schema node reachable from the roots, following `$ref`
   edges. Each object schema it finds becomes a compiled record.
3. Each generator turns the records into source files, one file per
   class, and formats them with SyntaxTree.

Nothing is fetched from the network. A schema URI that points at another
host resolves to a local file through schema directories (`--schema-dir`).

## The design rule

Generated code represents every instance the schema accepts. A schema
feature with no exact Ruby rendering widens the generated type instead of
narrowing acceptance. The generated classes do not validate: they shape
data. Constraints such as `pattern`, `minimum`, or `format` never reach
the output.

## Manual contents

- [Getting started](getting-started.md): install, first schema, first
  output.
- [Command line reference](cli.md): every option, inputs, outputs,
  logging, exit behavior.
- [Library API](library-api.md): `Schematrix.generate`, the error types,
  driving generators from Ruby.
- [Generators](generators.md): the four output formats and their type
  mappings.
- [Generated code](generated-code.md): what a generated class contains
  and how loading and dumping work.
- [Schema features](schema-features.md): every supported keyword, and
  how composition and references compile.
- [Names and files](naming.md): how class names, module nesting, and
  file paths derive from your schema.
- [Limits and approximations](limits.md): what is ignored, and where the
  output accepts more than the schema requires.
