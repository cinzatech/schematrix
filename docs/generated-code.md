# Generated code

Every data generator produces the same runtime shape: classes that hold
data, load documents, and dump documents. This page describes that
shape. The samples show `plain_ruby` output; `sorbet_ruby` adds
signatures to the same bodies, and `rbi`/`rbs` declare the same surface.
The `dsl_` generators produce builders instead, documented in
[The instance DSL](dsl.md).

## Class anatomy

For `person.schema.json` from [Getting started](getting-started.md):

```ruby
module MyApp
  class Person
    ORIGINAL_KEYS = {
      "firstName" => :first_name,
      "lastName" => :last_name,
      "age" => :age
    }.freeze

    def initialize(first_name:, last_name:, age: nil)
      @first_name = first_name
      @last_name = last_name
      @age = age

      @_extra = {}
    end

    attr_accessor :first_name, :last_name, :age

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    # ... from_h and to_h follow, shown below
  end
end
```

The pieces:

- `ORIGINAL_KEYS` maps each original property name from the document to
  the generated accessor name. It is the contract every other piece
  reads and writes under.
- The constructor takes one keyword argument per property. `firstName`
  and `lastName` are required in the schema, so their keywords carry no
  default; `age` is optional and defaults to `nil`.
- One accessor per property.
- `[]` and `[]=` store anything the schema did not declare. They exist
  when the class accepts extra keys, that is, when
  `additionalProperties` is not closed.
- `from_h` and `to_h` (below).

## Loading and dumping

`from_h` builds an instance from a hash as parsed from a document,
with String keys:

```ruby
person = MyApp::Person.from_h(
  { "firstName" => "Ada", "lastName" => "Lovelace", "nickname" => "Ada" }
)
person.first_name # => "Ada"
person["nickname"] # => "Ada" (extra key, rides the catch-all)
```

Rules:

- Known keys land in their slots under their original spelling:
  the document says `"firstName"`, the accessor is `first_name`.
- Values of properties that carry a nested class are coerced: a `Hash`
  loads through that class's own `from_h`, an instance passes through,
  anything else passes through unchanged. The same dispatch dumps in the
  other direction through `to_h`.
- Values of properties whose scalar `format` maps to a coercer (`date`,
  `date-time`, or a project's own) convert the same way at every
  position the formatted type renders: a document string loads through
  the coercer, an instance dumps through it, arrays convert
  elementwise (tuple positions each through their own coercer), maps
  and catch-all riders convert their values, and union branches
  dispatch on the value's class. The converter is emitted into the
  file, so these slots need no gem at runtime.
- A property with a schema `default` keeps that default when the key is
  absent from the hash. `from_h` assigns defaulted properties only when
  the key is present.
- Unknown keys ride the catch-all under their original String names, on
  load and on dump.

`to_h` is the inverse:

```ruby
person.to_h
# => { "firstName" => "Ada", "lastName" => "Lovelace", "nickname" => "Ada" }
```

`nil` slots are omitted from the dump. Absent keys therefore stay absent
across a round trip, and unknown keys survive unchanged.

A required keyword fed `nil` by `from_h` (the key was absent) does not
raise. Loading accepts more than the schema does; the data can be
validated elsewhere.

## Property names

Schema property names become Ruby identifiers:

1. Snake case: `firstName` becomes `first_name`, `HTTPServer` becomes
   `http_server`.
2. A leading `$` is dropped: `$id` becomes `id`, `$ref` becomes `ref`.
3. Characters an identifier cannot carry become underscores:
   `web/hook` becomes `web_hook`.
4. A leading digit gains an underscore prefix.
5. A Ruby keyword gains a trailing underscore: `if` becomes `if_`.

The original name stays reachable: `ORIGINAL_KEYS` records the mapping,
`from_h` reads the original spelling, and `to_h` writes it back.

Two sibling property names can fold onto one accessor (`"foo-bar"` and
`"foo_bar"` both become `foo_bar`). The generator keeps the first
declaration's schema, keeps the first original key for load and dump,
and logs a warning naming both. Splitting the names in the schema
silences it.

## Defaults

A schema `default` becomes the constructor default:

```json
{ "type": "string", "default": "blue" }
```

```ruby
def initialize(color: "blue")
```

`from_h` leaves defaulted slots untouched when the document omits the
key, so an explicit `null` in the document and an absent key stay
distinct: `{"color": null}` sets `nil`, an absent key keeps `"blue"`.

## Closed shapes

With `--closed-shapes`, or an explicit `"additionalProperties": false`,
a class has no catch-all: no `[]`, no `[]=`, no `@_extra`, and `from_h`
drops keys it does not know. See
[Schema features](schema-features.md).

## File layout

One file per class, in the output directory, at a path that mirrors the
class nesting:

```text
app/generated/person.rb
app/generated/complex_object.rb
app/generated/complex_object/props/address.rb
```

Each file reopens its enclosing modules and classes, so files load in
any order. See [Names and files](naming.md) for how names and paths
derive from the schema.
