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
  dispatch on the value's class. Every conversion is a frozen literal
  that the property's `coerce_` method hands to the shared
  `CoercionHelper` module: the file the `auxiliary_files` generator
  writes once per output directory, and that every converting class
  file requires. Generated code depends on nothing but the generated
  set itself.
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
4. A name left with nothing representable (only punctuation, or
   script without Latin characters) folds to its UTF-8 hex instead:
   `名前` becomes `e5908de5898d`, so distinct names stay distinct.
5. A leading digit gains an underscore prefix.
6. A Ruby keyword gains a trailing underscore: `if` becomes `if_`.

The original name stays reachable: `ORIGINAL_KEYS` records the mapping,
`from_h` reads the original spelling, and `to_h` writes it back. The
class a nested object property generates folds the same hex, so the
declaring file and the referencing parent agree on one constant; see
[Names and files](naming.md).

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

## Maybe optionals

With `optionals: :maybe` on a generator instance, every property not
listed in `required` types as `Maybe[T]` instead of a nilable type,
and required properties keep their type.

The Maybe type has two cases, `Present(value)` and `Absent`, and
carries nullability inside the type: `Maybe[T.nilable(Integer)]` has
three states, `Absent` for a missing key, `Present(nil)` for a null,
and `Present(36)` for a value. Loading and dumping follow the
document:

- `from_h` builds `Absent` when the key is missing and
  `Present(value)` when it is there, `null` included.
- `to_h` writes nothing for `Absent` and writes the value for
  `Present`, `null` included.
- A schema `default` is the constructor default, as `Present(default)`,
  so an absent key still loads the default and dumps it.

The distinction is the content of a partial update: `{"age": null}`
means "clear the age", an omitted `age` means "leave it alone".

Without further options the generator writes its own `MyApp::Maybe`
into the output module, once per output directory, so generated code
keeps its property of depending on nothing but `sorbet-runtime` in the
Sorbet formats. The generated module declares `interface!` and
`sealed!`, so a `case` over a `Maybe` checks for exhaustiveness and
`T.absurd` works; `value` is deliberately not on the interface, so
calling it on an `Absent` does not type check; `Absent` is one frozen
instance.

A project that already has a Maybe passes it with `maybe:`:

```ruby
Schematrix::Generators::SorbetRuby.new(
  "app/generated",
  "MyApp",
  optionals: :maybe,
  maybe: ::Maybe,
)
```

The module must answer `from(value)` and `empty`, and its instances
`present?` and `when_present { |value| }`; the generator checks the
four at generation time and refuses anything else before any file is
written. With a supplied Maybe the generated dump reads through
`when_present` instead of the sealed `case`, because the generator
cannot assume a supplied type is sealed. The `dsl_` builders do not
accept the option: a builder expresses absence by never calling a
setter, which is already the right behaviour.

## Partial classes

The `partial_` generators ([Generators](generators.md)) write a second
family where every property wraps in the Maybe type, required ones
included, under a `Partial` module level:

```ruby
sig { params(first_name: Maybe[String], age: Maybe[T.nilable(Integer)]).void }
def initialize(first_name: Maybe.empty, age: Maybe.empty)
```

Every keyword carries a `Maybe.empty` default, so an empty partial is
one constructor call away. A nested object property types as
`Maybe[Partial::Address]`. A schema `default` does not materialize
from nothing in a partial: the slot starts `Absent` when the document
lacks the key, and wraps the document's value as `Present(value)` when
it carries it, so an empty patch document dumps as an empty hash.

## Closed shapes

With `--closed-shapes`, or an explicit `"additionalProperties": false`,
a class has no catch-all: no `[]`, no `[]=`, no `@_extra`, and `from_h`
drops keys it does not know. See
[Schema features](schema-features.md).

## Immutable classes

With `immutable: true` on a generator instance, or `--immutable` on the
command line, the four data generators write frozen value objects
instead of mutable classes. Loading and dumping rules do not change:
`from_h` accepts the same documents and `to_h` produces the same
hashes. For `person.schema.json` from [Getting
started](getting-started.md), `plain_ruby` writes:

```ruby
module MyApp
  class Person
    ORIGINAL_KEYS = {
      "firstName" => :first_name,
      "lastName" => :last_name,
      "age" => :age
    }.freeze

    def initialize(first_name:, last_name:, age: nil, _extra: {})
      @first_name = first_name
      @last_name = last_name
      @age = age
      @_extra = _extra.freeze
      freeze
    end

    attr_reader :first_name, :last_name, :age

    def [](key)
      @_extra[key]
    end

    def with(first_name: @first_name, last_name: @last_name, age: @age, _extra: @_extra)
      self.class.new(first_name: first_name, last_name: last_name, age: age, _extra: _extra)
    end

    def ==(other)
      other.is_a?(self.class) && other.first_name == @first_name &&
        other.last_name == @last_name && other.age == @age &&
        other._extra == @_extra
    end

    alias eql? ==

    def hash
      [self.class, @first_name, @last_name, @age, @_extra].hash
    end

    def self.from_h(hash)
      kwargs = {}
      kwargs[:first_name] = hash["firstName"]
      kwargs[:last_name] = hash["lastName"]
      kwargs[:age] = hash["age"]
      kwargs[:_extra] =
        hash.each_with_object({}) do |(key, value), extras|
          next if ORIGINAL_KEYS.key?(key)

          extras[key] = value
        end
      new(**kwargs)
    end

    def to_h
      result = {}
      result["firstName"] = @first_name unless @first_name.nil?
      result["lastName"] = @last_name unless @last_name.nil?
      result["age"] = @age unless @age.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end

    protected

    attr_reader :_extra
  end
end
```

The differences from the default shape:

- `attr_reader` for every property. The writer methods are gone, so an
  accidental `person.age = 37` raises `NoMethodError` instead of
  mutating a document in place.
- The instance freezes at the end of the constructor, and the catch-all
  freezes with it. A frozen instance is safe to share between threads
  and to memoize.
- An open shape stays open on load and closed to writes afterwards:
  `[]` remains, `[]=` is gone. The unknown keys arrive through the
  `_extra:` keyword of the constructor, and `from_h` gathers them into
  that keyword, so what it accepts does not change. A closed shape has
  no `_extra:` keyword at all, exactly as it has no catch-all.
- `from_h` builds the instance in one constructor call, since nothing
  can be assigned afterwards. Defaulted properties still assign only
  when the document carries their key, so absence keeps the default.
- `with(**changes)` returns a new instance with the given properties
  replaced and everything else kept, the catch-all included, which the
  `_extra:` keyword replaces as a whole. The signature names one
  keyword per property, so the type checker sees the same contract as
  the constructor. A closed shape omits `_extra:` there too. The values
  pass to the constructor as given: a nested document loads through
  `from_h`, not through `with`.
- `==`, `eql?` and `hash` compare the class, every property, and the
  catch-all, so instances work in assertions, in `uniq`, and as Hash
  keys. The catch-all comparison reads the other instance through a
  protected `_extra` reader, which only instances of the class can
  call. It keeps the underscore of the keyword to stay clear of
  property readers.

In use:

```ruby
person = MyApp::Person.from_h(doc)
older = person.with(age: 37)
older.frozen?                  # => true
person.age                     # => 36
older == person.with(age: 37)  # => true
[person, person.with(age: 36)].uniq.size # => 1
```

`with` and `hash` are generated method names, so a property named
`with` or `hash` (a checksum field, say) would override one. Like the
DSL's `build` and `to_h`, the names are reserved: a property named
`with` or `hash` gains the trailing underscore treatment, with
`ORIGINAL_KEYS` recording the mapping. `_extra` joins the reservation
because the constructor keyword and the protected reader carry that
name. A property named `with_`, `hash_` or `_extra_` is untouched, and
two siblings can still fold onto one accessor, with the collision
warning of [Property names](#property-names).

The option applies to the data generators only. The `dsl_` builders
are unaffected: a builder is mutable by construction, it accumulates a
document. Passing `immutable: true` to a DSL generator raises
`ArgumentError`.

The Sorbet signatures follow the runtime shape: the readers, `with`
(`returns(T.self_type)`, so subclasses copy as themselves), `==` and
`hash` all carry signatures, and the `[]=` signature is gone.

## File layout

One file per class, in the output directory, at a path that mirrors the
class nesting:

```text
app/generated/person.rb
app/generated/complex_object.rb
app/generated/complex_object/props/address.rb
```

The DSL builders live under a `dsl/` prefix and the partial classes
under a `partial/` prefix, at the same depth, so three families can
share one output directory and one module:

```text
app/generated/person.rb                  # MyApp::Person
app/generated/partial/person.rb          # MyApp::Partial::Person
app/generated/dsl/person.rb              # MyApp::Dsl::Person
```

Each file reopens its enclosing modules and classes, so files load in
any order. See [Names and files](naming.md) for how names and paths
derive from the schema.
