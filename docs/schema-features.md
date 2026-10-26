# Schema features

This page lists what the compiler understands, keyword by keyword, and
what it does with each. The design rule from the
[manual](manual.md) holds throughout: generated code accepts every
instance the schema accepts, and widens rather than rejects when a
feature has no exact Ruby rendering.

## Dialects

The compiler targets draft 2020-12. At load time it checks the
`$schema` header: a document naming another dialect fails with
`UnsupportedDialectError` instead of being read with wrong semantics. A
document without a header is read as 2020-12. Both the `https` and the
`http` spelling of the meta URI are accepted, with or without a
trailing `#`.

A document must parse to an object or a boolean; anything else fails
with `InvalidSchemaError`.

## Types

- `type` as a string or as an array (`["string", "null"]` renders as a
  union, `String | nil` style).
- `const` with no declared type infers the type from the value:
  `{"const": "active"}` types the property as `String`. Values that do
  not map to a clean scalar type infer nothing.
- `enum` with no declared type infers the union of its values' types.
  Values without a clean mapping contribute nothing.
- A schema that is just `true` accepts anything: it types as
  unconstrained (`T.anything` / `top`) and creates no class. A schema
  that is just `false` accepts nothing and contributes nothing.

The `description` annotation becomes a comment above the generated
class. `title` is captured but unused. Constraint keywords such as
`pattern`, `minimum`, `minLength` never reach the output: the generated
classes shape data, they do not validate it.

## Formats

A scalar slot's `format` picks the Ruby type the slot renders, from the
scalar type table the compiler carries:

| Schema shape                                  | Rendering (Sorbet / RBS) |
| --------------------------------------------- | ------------------------ |
| `{ "type": "string" }`                        | `String` / `String`      |
| `{ "type": "string", "format": "date" }`      | `Date` / `Date`          |
| `{ "type": "string", "format": "date-time" }` | `Time` / `Time`          |

The `date` and `date-time` entries also carry a coercer, and every
slot the type algebra renders from a coercing entry converts on load
and dump: a document string loads through `Date.iso8601` /
`Time.iso8601`, an instance dumps through `iso8601`, and anything else
passes through unchanged. That covers plain scalar properties, array
elements and tuple positions, map and catch-all values, and union
branches. The coercion code is emitted into the generated file itself,
so the output keeps no runtime dependency on this gem. See
[Generated code](generated-code.md).

One union shape cannot convert: branches that would convert the same
JSON type through different coercers, such as `anyOf` of `date` and
`date-time`. The value carries no mark of its branch, so generation
fails with `CoercionConflictError` instead of emitting a
converter that is wrong for every instance of the branch whose
coercer it does not use.

A format with no table entry renders as its bare type, exactly as if
it were absent. A project maps its own formats to its own classes
through a generator's `scalar_types:` option, which merges over the
built-in table:

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

A coercer is any named module answering `coerce(value)`, following the
same rule: a document value loads, an instance dumps, anything else
passes through. An entry with `coercer: nil` maps a format to a type
without conversion. The schema stays plain JSON Schema with annotation
formats, which every other tool reads unchanged. See
[Library API](library-api.md) for the option and
[Limits](limits.md) for the conversion contract and its one
non-convertible shape.

## Properties

`properties` and `required` drive the constructor and the accessors:

- A required property with no `default` becomes a constructor keyword
  without a default.
- Every other property becomes a keyword defaulting to `nil`, or to its
  `default` value when one is declared.
- A property typed `null` (alone) is optional: `nil` is a value it
  admits.

## Objects and additionalProperties

| `additionalProperties` | Generated shape                                     |
| ---------------------- | --------------------------------------------------- |
| absent                 | open catch-all: unknown keys accepted and stored    |
| `false`                | closed class: unknown keys dropped                  |
| a schema               | open catch-all, values typed by that schema         |

`--closed-shapes` (or `closed_shapes:` in the library) flips the
absent case to closed, per run.

An object with **no own properties** and a non-closed catch-all is a
map, not a class:

```json
{ "type": "object", "additionalProperties": { "type": "string" } }
```

This compiles to `Hash[String, String?]`-style slot types (the value
type carries a nil term when the catch-all admits null), and no class
file is generated for it. An explicit `false` catch-all on an object
with no properties is an empty object and keeps its class.

## Arrays

- `items` types the element. An array with `items` absent has an open
  tail: the element type gains an unconstrained term.
- `prefixItems` types positions. A tuple's element type is the union of
  the prefix types, the `items` type when present, and the open-tail
  term when the tail is open. `items: false` closes the tail.
- Arrays of objects: `$ref` items keep their target classes; inline
  object entries inside `prefixItems` have no stable class name and fall
  back to unconstrained.
- An array property in several `allOf` branches intersects its element
  types; across `anyOf`/`oneOf` branches the element types union.

## Composition

How a composition keyword compiles depends on where the schema sits.

At the document root, or on any schema typed `object`, the branches
merge into one class:

- `allOf`: a property set conjunction. Properties from all branches
  merge; a property declared in several branches intersects its type
  declarations (`String & Integer`); `required` entries union;
  `additionalProperties` intersects (any `false` closes). A `false`
  branch would make the whole schema uninhabitable and is skipped.
- `anyOf` and `oneOf`: branch properties merge as optional additions to
  the parent's own. A property that only some branches mention gains an
  unconstrained term, because the branches that skip it accept any
  value for it.
- `then`, `else`, and each entry of `dependentSchemas`: their
  properties merge as optional. `if` is a condition and contributes
  nothing.
- These rules apply recursively, so `if`/`then`/`else` behaves as
  "the document may carry the `then` properties, or the `else`
  properties, or neither".

On a value schema (a property, an array element), the branches
contribute to the property's type instead:

- `allOf` conjoins: scalar branches intersect their type terms
  (`allOf: [string, integer]` types the slot `String & Integer`), a
  `$ref` branch keeps its target class (and that class generates),
  and an inline object branch merges its properties into the
  property's own class, as it does under `anyOf`. Branch facets with
  no codegen rendering (`minLength`, ...) contribute nothing.
- Scalar branches of the union keywords become union terms:
  `anyOf: [string, integer]` types the slot `String | Integer`.
- Inline object branches inside `anyOf` merge into the property's own
  class.
- Inline object branches inside `oneOf` become their own positional
  classes, named `OneOf0`, `OneOf1`, and so on, nested under the
  property's class.
- `$ref` branches keep their target classes and union with the other
  terms.
- At the document root, `anyOf` and `oneOf` merge properties exactly
  like `allOf` does, because a root always compiles to one class.

## References

- `$ref` to an object schema: the property types as the target's class,
  and that class is generated. Chains of `$ref` to `$ref` follow to the
  final target. A definition whose own `$ref` sits beside
  shape-applying keywords is itself the target (2020-12 applies
  both): the chain stops there, and its sibling `$ref` applies when
  the definition compiles. This is the OpenAPI 3.1 schema idiom,
  where nearly every definition carries the
  `specification-extensions` hook beside its own keywords.
- `$ref` to a scalar schema: the target's type compiles in place of the
  reference.
- `$ref` to `true`: only the reference's own siblings remain, which
  types as unconstrained when the `$ref` stood alone. `$ref` to
  `false`: the schema accepts nothing.
- Siblings beside a `$ref`: draft 2020-12 applies both. When a sibling
  changes the shape (`type`, `properties`, `required`, `items`, and
  friends), the node compiles as the conjunction of the target and the
  siblings, which becomes its own class. Annotation-only siblings such
  as `description` ride along without disturbing the reference.
- `$defs` schemas get classes like any other object schema, nested
  under a `Defs` module level. See
  [Names and files](naming.md).
- `$anchor`: a plain-name fragment (`"#foo"`) resolves through the
  document's `$anchor` index.
- `$dynamicRef`: resolved statically, to the nearest enclosing
  `$dynamicAnchor` with that name between the reference site and the
  document root, else to the last `$dynamicAnchor` in the document.
  When neither exists, the slot types as unconstrained and the fallback
  is logged at debug level.

## Remote references

A `$ref` whose URI points at another host never touches the network. It
resolves to a file under a schema directory, mirroring the URI as
`host/path`:

```text
https://json-schema.org/draft/2020-12/meta/core
```

resolves, under `vendor/schemas` (the CLI default), to the first
existing file among:

```text
vendor/schemas/json-schema.org/draft/2020-12/meta/core
vendor/schemas/json-schema.org/draft/2020-12/meta/core.json
vendor/schemas/json-schema.org/draft/2020-12/meta/core.yaml
vendor/schemas/json-schema.org/draft/2020-12/meta/core.yml
```

Rules:

- `--schema-dir` may repeat; directories are searched in order and the
  first match wins. Explicit directories replace the
  `vendor/schemas` default, they do not add to it.
- A non-default port stays in the host segment
  (`example.com:8443/...`).
- A URI with a query string cannot map, and a mapped path cannot carry
  `.` or `..` segments. Both fail with `UnresolvableLocatorError`.
- A miss fails with an error listing every candidate path.

This repository vendors the eight draft 2020-12 meta documents under
`vendor/schemas`, so schemas referencing
`https://json-schema.org/draft/2020-12/...` resolve when run from a
checkout.

## Ignored keywords

Keywords with no codegen rendering are skipped, and each skip is logged
once per document at debug level. Shapes stay open:

`not`, `unevaluatedProperties`, `unevaluatedItems`, `contains`,
`minContains`, `maxContains`, `dependentRequired`,
`patternProperties`, `propertyNames`.

Extra keys land in the catch-all where one exists, so ignoring these
widens acceptance instead of dropping data.
