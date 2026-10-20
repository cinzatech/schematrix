# Generators

A generator renders compiled schema records as source files. Four exist:

| Name | Files | Contents |
| ------------- | ----- | -------- |
| `plain_ruby` | `.rb` | Mutable Ruby classes, no type annotations. |
| `sorbet_ruby` | `.rb` | Mutable Ruby classes with inline Sorbet `sig` blocks, `# typed: strict`. |
| `rbi` | `.rbi` | Sorbet interface files: signatures only, empty bodies. |
| `rbs` | `.rbs` | RBS signature files. |

All four walk the same compiled records, so one schema produces the same
classes under every format. All four format their output with SyntaxTree
(`syntax_tree` for Ruby, `syntax_tree-rbs` for RBS). Pass `format:
false` to [a generator instance](library-api.md) to skip that step.

## What every generator emits

For each object schema the compiler found, one file per class:

- A keyword-argument constructor. Required properties are positional
  keyword arguments without defaults; every other property defaults to
  `nil`, and properties carrying a schema `default` use that value.
- One accessor per property, plus its entry in `ORIGINAL_KEYS`.
- Catch-all accessors `[]` and `[]=` when the class accepts extra keys.
- `from_h` and `to_h` for loading and dumping, with one `coerce_` method
  per property whose values carry a nested class.

The details live in [Generated code](generated-code.md).

## plain_ruby

The plain format writes runnable Ruby with no runtime dependencies.
`person.schema.json` from [Getting started](getting-started.md)
generates a class you can require and use directly; see that page for
the full output. The same schema with a nested object produces one file
per class, nested under directories that mirror the class nesting.

## sorbet_ruby

The Sorbet format writes the same classes with `sig` blocks and real
bodies, under a `# typed: strict` header. The file loads without
`sorbet-runtime` installed, but type checking with `srb tc` requires
the `sorbet-runtime` gem at runtime.

```ruby
# typed: strict

module MyApp
  class ComplexObject
    ORIGINAL_KEYS = { "name" => :name, "address" => :address }.freeze

    sig do
      params(
        name: T.nilable(String),
        address: T.nilable(ComplexObject::Props::Address)
      ).void
    end
    def initialize(name: nil, address: nil)
      @name = name
      @address = address

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :name

    sig { returns(T.nilable(ComplexObject::Props::Address)) }
    attr_accessor :address

    # ... the []= accessor, coerce_ methods, from_h and to_h follow,
    # with the same bodies the plain_ruby generator emits
  end
end
```

## rbi

The RBI format writes signature-only files with empty method bodies, the
shape `sorbet` consumes for static analysis. Signatures match the
`sorbet_ruby` output. `# typed: strict` applies.

```ruby
sig { params(name: T.nilable(String)).void }
def name; end

sig { params(hash: T::Hash[String, T.anything]).returns(Person) }
def self.from_h(hash); end
```

## rbs

The RBS format writes `.rbs` signatures, one module tree per class. Type
names inside a signature are relative (`ComplexObject::Props::Address`),
which resolves lexically from the enclosing class.

```rbs
module MyApp
  class Person
    attr_accessor first_name: String
    attr_accessor last_name: String
    attr_accessor age: Integer?

    def initialize: (
      first_name: String,
      last_name: String,
      ?age: Integer?
    ) -> void

    def []: (String) -> top

    def []=: (String, top) -> top

    def self.from_h: (Hash[String, top] hash) -> Person

    def to_h: -> Hash[String, top]
  end
end
```

## Type mappings

How a JSON Schema type renders per notation:

| Schema type      | Sorbet (`rbi`, `sorbet_ruby`) | RBS (`rbs`)         |
| ---------------- | ----------------------------- | ------------------- |
| `string`         | `String`                      | `String`            |
| `integer`        | `Integer`                     | `Integer`           |
| `number`         | `Numeric`                     | `Numeric`           |
| `boolean`        | `T::Boolean`                  | `bool`              |
| `null`           | `NilClass`                    | `nil`               |
| object           | the generated class           | the generated class |
| array            | `T::Array[E]`                 | `Array[E]`          |
| map              | `T::Hash[String, V]`          | `Hash[String, V]`   |
| no `type` at all | `T.anything`                  | `top`               |
| `false` schema   | `T.noreturn`                  | `top`               |

Absence wraps a type: an optional property renders as `T.nilable(T)` in
Sorbet and `(T)?` in RBS. A union of declared types renders as
`T.any(A, B)` and `A | B`. An intersection renders as `T.all(A, B)` and
`A & B`. `plain_ruby` emits no annotations; optionality shows up as
constructor defaults there.

Inside a union, a `false` branch contributes no term in either
notation: it accepts nothing, so the other branches speak for the slot.

RBS renders `top` where Sorbet renders `T.anything`: any value assigns
into `top`, but a read from it must be narrowed before use. Sorbet's
`T.anything` has the same shape.

A property typed only `["object", "null"]` through a `$ref` keeps its
class and renders nilable instead of collapsing to `nil`.

## Maps

An object schema with no own properties and a non-closed
`additionalProperties` is a map, not a class: the slot types as
`Hash[String, V]` where `V` is the catch-all value type, and no class
file is generated for it.

```json
{
  "type": "object",
  "additionalProperties": { "type": "integer" }
}
```

This schema generates nothing; a property holding it types as
`Hash[String, Integer?]`. The `Hash` value type carries an explicit nil
term only when the catch-all admits `null`.
