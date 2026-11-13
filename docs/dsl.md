# The instance DSL

The four DSL builder generators produce Ruby modules whose methods
describe an instance of the schema. A schema for people generates
`MyApp::Dsl::Person`, and a block of plain method calls on it defines one
document:

```ruby
MyApp::Dsl::Person.build do
  first_name "Ada"
  last_name "Lovelace"
  age 36
end
# => { "firstName" => "Ada", "lastName" => "Lovelace", "age" => 36 }
```

The block takes no parameter. `build` runs it on a fresh builder with
`instance_exec`, so inside the block `self` is the builder and every
call is a setter. The same holds for the block of a nested object.

The same source serves two readers:

- Ruby runs it. `build` returns the document as a Hash, ready for
  `JSON.generate` or for a generated data class' `from_h`.
- A generated `dsl_parser` reads it with Prism and reconstructs the same
  document statically, without running the file.

The output formats are the usual four: `dsl_plain_ruby` (`.rb`), with
`dsl_sorbet_ruby` (`.rb`, `# typed: strict`), `dsl_rbi` (`.rbi`), and
`dsl_rbs` (`.rbs`) adding signatures in their notations.

## Names and files

Builder modules nest under a `Dsl` module level inside your module, and
their files under a `dsl` directory inside the output directory:

```text
app/generated/person.rb                  # MyApp::Person, the data class
app/generated/dsl/person.rb              # MyApp::Dsl::Person, the builder
```

The two families can share one output directory and one module: the
prefix keeps them apart as constants and as files. Below the prefix the
names follow the same rules as the data classes, including the `Props`
and `Defs` levels (see [Names and files](naming.md)).

## Parsing without execution

Generate a parser on its own:

```sh
schematrix -g dsl_parser -m MyApp -o out input.json
```

For a `person.json` schema, the generator writes
`parser/person.rb`, `parser/runtime.rb`, and `parser/parse_error.rb`
under the output directory. The support files are automatic; do not
select a separate generator for them.

```ruby
require_relative "out/parser/person"

MyApp::Parser::Person.parse(<<~RUBY, filename: "ada.rb")
  MyApp::Dsl::Person.build do
    first_name "Ada"
    age 36
  end
RUBY
# => { "firstName" => "Ada", "age" => 36 }

MyApp::Parser::Person.parse_file("ada.rb")
```

`parse(source, filename: "(dsl)")` returns a Hash. `parse_file(path)`
reads the file and uses its path in diagnostics. Parser modules use
`extend self`: both methods are callable on the module and can be
included in an application class. An override can call `super`.

The parser accepts one fully qualified `MyApp::Dsl::Person.build`
call with a block that takes no parameters. It also accepts a class or
module declaration containing `extend MyApp::Dsl::Person` and setter
calls, including declarations inside nested namespace wrappers. The
`extend` may sit anywhere in the body, as long as it is the only one
for that builder, and every other statement is a setter call. That
order rule is parse-only: Ruby runs a class body in order, so a
setter that precedes the `extend` raises `NoMethodError` when the
file executes, while the parser accepts it. The parser neither
executes the source nor creates its declared constants. Builder and
enum classes do not need to be loaded; enum constants resolve
statically from the generated metadata.

Unknown setters, variables, expressions, `require`, assignments,
interpolation, splats, and extra top-level statements are rejected.
A configured scalar reader is the only explicit exception for nonliteral
values (see below). The generated code needs the standard library and
Prism 1.4 or later, but does not need Schematrix at runtime.

Errors raise `MyApp::Parser::ParseError`, with `filename`, `line`,
`column`, `keyword`, and `reason` fields. Lines and columns are 1-based.
The `keyword` names the setter being applied. Failures inside a
setter's arguments or block keep that setter's keyword, even when the
exact node is a value expression or a reader call; `keyword` is `nil`
only when the rejected statement itself is not a setter call. If a
scalar reader raises, the parse error retains that exception as its
`cause`.

## Builder anatomy

Each builder is a module that carries:

- `ORIGINAL_KEYS`, the map from method names to the schema's original
  property names. The methods spell snake case; the document keeps its
  original keys. The parser carries its own generated mapping.
- `self.build`, the entry point: a fresh `Builder`, the block run on
  it with `instance_exec`, and its document returned.
- One setter per property, shaped by the property's compiled form (next
  section), under a comment when the property has a `description`.
  Setters return the receiver, so calls chain outside blocks.
- `extra`, when the shape is open: a home for keys the schema does not
  declare. A closed shape has no `extra`.
- `to_h`, returning the document built so far.
- `Builder`, a nested empty class that includes the module. It is what
  `build` runs the block on.

The document lives in an instance variable that the first setter
creates, so the module has no initializer and works on any receiver.

## Mixing a builder in

A builder is a module so that a project can make the DSL its own.
`extend` puts the setters on a class, and the class body becomes the
declaration:

```ruby
class Ada
  extend MyApp::Dsl::Person

  first_name "Ada"
  last_name "Lovelace"
end

Ada.to_h # => { "firstName" => "Ada", "lastName" => "Lovelace" }
```

`include` puts them on instances, each holding its own document. A
project class that includes a builder can add its own methods next to
the setters; the generated names it has to leave alone are `build`,
`to_h`, `extra`, `dsl_fields`, the nested `Builder`, and the instance
variable `@dsl_fields` that holds the document.

A nested object is declared the same way in a class body as in a
`build` block: its block runs on the child builder, so a project
method of the enclosing class is not callable inside it, while
constants still resolve lexically.

```ruby
module Schemas
  module Ada
    extend MyApp::Dsl::Person

    first_name "Ada"
    address do
      street "Plaza Santa Rita"
    end
  end
end
```

## The call grammar

A setter's form follows the property's compiled shape. Each call writes
under the property's original key.

| Property shape | Call | Document effect | Repeat rule |
| -------------- | ---- | --------------- | ----------- |
| scalar, union, enum in `:unions` mode | `age 36` | `doc["age"] = 36` | last call wins |
| enum in `:classes` mode | `status MyApp::Person::Props::Status::Active` | stores the member's serialized value | last call wins |
| object | `address do ... end`, or `address` | child document through `Address.build`; `{}` without a block | merges into a held Hash, replaces anything else |
| array of scalars | `hobbies "a", "b"` | appends one element per argument | appends |
| array of objects | `friends do ... end`, or `friends` | appends one built element per call; `{}` without a block | appends |
| map | `labels "k", 1` | `doc["labels"]["k"] = 1` | last call wins per key |
| map of objects | `metadata "k" do ... end`, or `metadata "k"` | entry built through the value builder; `{}` without a block | last call wins per key |
| open shape (catch-all) | `extra "k", v` | `doc["k"] = v` | last call wins |

A call without a block declares an empty object, for the three shapes
that take their value from a block:

```ruby
address               # "address": {}
friends               # appends {}
metadata "mentor"     # "metadata": { "mentor": {} }
```

The repeat rules are the same as for a call with an empty block. A bare
`address` after `address do ... end` merges nothing and keeps the held
Hash. The catch-all `extra` of an open shape with object values still
needs its block.

A property whose shape unions scalars with an object class takes both
forms (`option "fast"` and `option do foo 1 end`); the block's
presence decides. A bare `option` stores `nil`, not an empty object.
An array whose element does the same accepts variadic scalar elements
and block elements on one method. A bare call on that array declares
the empty array and appends nothing.

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

Class-mode enums are the exception to the literal contract. Their
setter signatures accept enum members, not raw strings or integers:

```ruby
MyApp::Dsl::Person.build do
  status MyApp::Person::Props::Status::Active
end
# => { "status" => "active" }
```

A parser must resolve the member constant to its serialized value.
`status "active"` still runs in the plain builder, but fails
`srb tc` against the class-mode signature. Sorbet runtime signature
checks can also reject it. The setter body serializes members and
passes non-members through without validation. Arrays serialize each
member argument; tuple arguments use their positions, including across
repeated setter calls. Maps serialize each member value. The resulting
`to_h` document carries raw values, ready for a data class's `from_h`.

Enum setters stay scalar-shaped; they do not take an object builder
block. Nilability follows the generated signature. DSL signatures use
absolute enum class references such as
`::MyApp::Person::Props::Status`, without a `Dsl` prefix, to avoid
namespace shadowing. Only the `*_enums` generators write those classes.

Built-in date and date-time setters dump `Date` and `Time` objects to
ISO strings and leave literal ISO strings untouched. Their DSL setter
signatures type the slot as `String`, so a definition file spells the
ISO string the parser accepts. A `scalar_types:` remap of either
format replaces that spelling like any other format. There is no
built-in reader for expressions such as `Date.new(2025, 1, 1)`.

JSON scalar literals pass through project coercers unchanged, on both
paths: a literal string stays the string it spells, and the document
holds document values, ready for a data class's `from_h`. A coercer
runs when the setter receives a project value that is not a JSON
scalar. This applies to nested arrays, maps, tuple positions, and
extra values with formats. For other values, the runtime stores what
the setter receives. The parse contract bounds what a data file may
contain, not what the setter body accepts.

### Trusted scalar readers

A `ScalarType` can have a `reader:` module or class with a `.read(node)`
method. The parser calls it only for a nonliteral Prism node in that
configured format slot. It must return the final document value; the
parser does not coerce that result again. Literal nodes keep the
values they spell.

Readers apply at the same formatted positions as coercers, including
nested containers and extra values. They do not enable expressions in
unrelated slots. A reader is trusted application code, so its behavior
is outside the parser's no-execution guarantee. The application must
load the reader and its dependencies before parsing. See
[Scalar types](library-api.md#scalar-types) for configuration.

## Required and defaults

Builders and parsers do not enforce `required` and do not apply `default`. The
document holds exactly what the source declared, so the parse path and
the run path cannot diverge. Defaults materialize when a data class
loads the document; validation happens outside the generated code, as
everywhere in schematrix.

## Sorbet

The Sorbet format declares every setter, under `# typed: strict`. Setter
value types come from the schema: `String` for a string property,
`T.any(String, Integer)` for a union. Unremapped built-in `date` and
`date-time` slots type as `String`, so a typed definition file spells
the ISO string the parser accepts; a `scalar_types:` remap keeps its
own spelling. A block is declared with
`T.nilable(T.proc.bind(Child).void)`. The proc type is the type of a
block that `instance_exec` runs on the child builder, so the calls
inside it typecheck against the child. The nilable wrap admits the call
without a block. Setters return `T.self_type`, so chains check.

The RBS format declares the same setters, with a bare optional block,
`?{ -> void }`.
RBS can bind a block's `self` to the child builder, but syntax_tree-rbs
1.0, which formats the output, drops that binding, so a Steep user sees
an untyped block.

Instance files type-check too. Mark them `# typed: true` and check them
together with the generated builders:

```ruby
# typed: true

MyApp::Dsl::Person.build do
  age "36"        # Expected Integer, found String
  first_nmae "x"  # Method does not exist, did you mean first_name?
end
```

Literals and type checking compose: `srb tc` proves every value fits its
slot before a parser ever reads the file.

## Reserved names

A property named `build`, `to_h`, `extra`, or `dsl_fields` would
override a builder method of the same name. It takes the keyword
treatment: a trailing underscore (`to_h` becomes `to_h_`), with
`ORIGINAL_KEYS` still recording the mapping. Property names that fold
together warn, as they do for data classes.

## Limits

- Builders and parsers shape data; they never validate. `pattern`, `minimum`, and
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
