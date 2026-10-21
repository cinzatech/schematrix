# The instance DSL

The four `dsl_` generators produce builders: Ruby classes whose methods
describe an instance of the schema. A schema for people generates
`MyApp::Dsl::Person`, and a block of plain method calls on it defines one
document:

```ruby
MyApp::Dsl::Person.build do |person|
  person.first_name "Ada"
  person.last_name "Lovelace"
  person.age 36
end
# => { "firstName" => "Ada", "lastName" => "Lovelace", "age" => 36 }
```

The same source serves two readers:

- Ruby runs it. `build` yields the builder and returns the document as a
  Hash, ready for `JSON.generate` or for a generated data class'
  `from_h`.
- A parser reads it. The call grammar below is small and regular, so a
  syntax walker (for example over Prism) reconstructs the same document
  statically, without running the file.

The output formats are the usual four: `dsl_plain_ruby` (`.rb`), with
`dsl_sorbet_ruby` (`.rb`, `# typed: strict`), `dsl_rbi` (`.rbi`), and
`dsl_rbs` (`.rbs`) adding signatures in their notations.

## Names and files

Builder classes nest under a `Dsl` module level inside your module, and
their files under a `dsl` directory inside the output directory:

```text
app/generated/person.rb                  # MyApp::Person, the data class
app/generated/dsl/person.rb              # MyApp::Dsl::Person, the builder
```

The two families can share one output directory and one module: the
prefix keeps them apart as constants and as files. Below the prefix the
names follow the same rules as the data classes, including the `Props`
and `Defs` levels (see [Names and files](naming.md)).

## Builder anatomy

Each builder carries:

- `ORIGINAL_KEYS`, the map from method names to the schema's original
  property names. Loading and parsing both read it; the methods spell
  snake case, the document keeps its original keys.
- `self.build`, the entry point: a fresh builder, yielded to the block,
  and its document returned.
- One setter per property, shaped by the property's compiled form (next
  section). Setters return the builder, so calls chain outside blocks.
- `extra`, when the shape is open: a home for keys the schema does not
  declare. A closed shape has no `extra`.
- `to_h`, returning the document built so far.

## The call grammar

A setter's form follows the property's compiled shape. Each call writes
under the property's original key.

| Property shape | Call | Document effect | Repeat rule |
| -------------- | ---- | --------------- | ----------- |
| scalar, union, enum | `age 36` | `doc["age"] = 36` | last call wins |
| object | `address do \|a\| ... end` | child document through `Address.build` | merges into a held Hash, replaces anything else |
| array of scalars | `hobbies "a", "b"` | appends one element per argument | appends |
| array of objects | `friends do \|f\| ... end` | appends one built element per call | appends |
| map | `labels "k", 1` | `doc["labels"]["k"] = 1` | last call wins per key |
| map of objects | `metadata "k" do \|m\| ... end` | entry built through the value builder | last call wins per key |
| open shape (catch-all) | `extra "k", v` | `doc["k"] = v` | last call wins |

A property whose shape unions scalars with an object class takes both
forms (`option "fast"` and `option do |o| o.foo 1 end`); the block's
presence decides. An array whose element does the same accepts variadic
scalar elements and block elements on one method.

Arrays of maps and arrays of arrays have no dedicated form: each
argument is one element, and a Hash or Array literal carries the inner
structure (`matrix [1, 2], [3, 4]`).

The parser's reconstruction mirrors the runtime rule for rule: overwrite
for scalars, shallow merge for repeated object calls, append for arrays,
and per-key overwrite for maps.

## Values

Inside a block, values are literals: strings, integers, floats, `true`,
`false`, `nil`, and, where a slot admits any JSON, Array and Hash
literals. This is the parse contract. A file that holds only literals
reconstructs statically, every node a known kind; a file that carries
`user_age` or `30 + 6` is out of contract, and a parser flags it instead
of guessing.

The runtime is looser: setters store whatever they receive, over-accepting
the same way `from_h` does. The contract bounds what a data file may
contain, not what the code accepts.

## Required and defaults

Builders do not enforce `required` and do not apply `default`. The
document holds exactly what the source declared, so the parse path and
the run path cannot diverge. Defaults materialize when a data class
loads the document; validation happens outside the generated code, as
everywhere in schematrix.

## Sorbet

The Sorbet format declares every setter, under `# typed: strict`. Setter
value types come from the schema: `String` for a string property,
`T.any(String, Integer)` for a union, the child builder's class in a
block's `T.proc` type. Setters return `T.self_type`, so chains check.

Instance files type-check too. Mark them `# typed: true` and check them
together with the generated builders:

```ruby
# typed: true

MyApp::Dsl::Person.build do |person|
  person.age "36"        # Expected Integer, found String
  person.first_nmae "x"  # Method does not exist, did you mean first_name?
end
```

Literals and type checking compose: `srb tc` proves every value fits its
slot before a parser ever reads the file.

## Reserved names

A property named `build`, `to_h`, `extra`, or `initialize` would
override a builder method of the same name. It takes the keyword
treatment: a trailing underscore (`to_h` becomes `to_h_`), with
`ORIGINAL_KEYS` still recording the mapping. Property names that fold
together warn, as they do for data classes.

## Limits

- Builders shape data; they never validate. `pattern`, `minimum`, and
  their friends have no effect, as for data classes.
- Schema `default` does not appear in builder output (see above).
- Tuples (`prefixItems`) feed the array setter positionally; a call
  cannot target one position.
- An array of arrays takes one inner array per argument; the literal
  form carries the inner structure, and deeper nesting has no dedicated
  spelling.
- Where several variants of a union carry object classes, the block
  form builds through the first one, matching the data classes' first
  class term.
