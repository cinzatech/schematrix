# Names and files

Every compiled object schema becomes one class in one file. This page
derives the names from the schema, so you can predict the output tree
before you run the tool.

## Class names

A class name is the schema's locator folded to PascalCase:

1. Take the input file's basename up to the first period:
   `payment-methods.schema.json` gives `payment-methods`.
2. Append the schema's path inside the document: the fragment
   segments (`properties`, `address`, `$defs`, `billing`, `anyOf_0`)
   joined with the file part. Each segment decodes first, so a
   locator and the property name it was built from fold to one name
   (`first%20name` and `first name` both give `FirstName`).
3. Fold each segment: characters a constant cannot carry (spaces,
   dashes, dots, punctuation) become word breaks, and the parts
   PascalCase together. `web.hook` becomes `WebHook`;
   `payment-methods` becomes `PaymentMethods`. A segment with no
   representable character at all folds to its UTF-8 hex, so `名前`
   becomes `E5908de5898d` instead of vanishing into the container
   name.
4. Container segments get fixed names: a `properties` segment becomes a
   `Props` module level, a `$defs` segment becomes a `Defs` module
   level.
5. A part that would start with a digit takes an `N` prefix, the
   closest a Ruby constant gets to `2fa`: it becomes `N2fa`. The same
   rule guards a schema file whose name starts with a digit.

Examples:

| Schema site | Class |
| ----------- | ----- |
| `person.schema.json` root | `Person` |
| `complex-object.schema.json` `#/properties/address` | `ComplexObject::Props::Address` |
| `order.schema.json` `#/$defs/lineItem` | `Order::Defs::LineItem` |
| `flat.schema.json` `#/properties/a/properties/b` | `Flat::Props::A::Props::B` |
| `payment.schema.json` `#/properties/method/oneOf/0` | `Payment::Props::Method::OneOf0` |

The `Props` and `Defs` levels are unconditional, so a property chain and
a definition chain can never fold onto the same class name.

A class's own Ruby nesting mirrors the name: `Flat::Props::A` is itself
a generated class, and `Props::B` nests inside it.

## Enum names

Qualifying enums use the same locator rules:

| Schema site | Enum class |
| ----------- | ---------- |
| `person.schema.json` `#/properties/status` | `Person::Props::Status` |
| `person.schema.json` `#/$defs/affiliation` | `Person::Defs::Affiliation` |
| `affiliation.schema.json` root | `Affiliation` |

Only the four `*_enums` generators write these files. The enum family
has no `Dsl` or `Partial` prefix: data classes, builders, and partials
share one set of member constants. Partial and DSL signatures use
absolute class references to avoid binding to a class in their own
namespace.

Member names fold from serialized values to PascalCase. For example,
`"in-progress"` becomes `InProgress`, and integer `1` becomes `N1`.
The `N` prefix makes digit-leading names valid Ruby constants; it is
not an underscore. Duplicate raw values produce one member. Distinct
values that fold to one constant raise `OutputCollisionError`.

The Sorbet Ruby and RBI enum generators also reject a member name that
equals the enclosing class's leaf name. For example, `"affiliation"`
in class `Affiliation` would declare `Affiliation::Affiliation`, which
Sorbet cannot type as the enclosing enum. This raises
`OutputCollisionError`. Plain Ruby and RBS permit that name. See the
[spike evidence](enum-spike.md).

## File layout

One file per class, under the output directory. The path is the class
name, snake cased, with `::` becoming directory separators:

```text
generated/order.rb
generated/order/defs/line_item.rb
generated/flat/props/a.rb
generated/flat/props/a/props/b.rb
```

Each file reopens the modules and classes above the one it defines, and
the kind matches what the file above it declared (`module` under
`module`, `class` under `class`). Files therefore load in any order:
require them in the order your application likes, or all at once with a
glob.

The `-m` flag wraps everything in that namespace:

```sh
schematrix -g plain_ruby -m "Acme::Contracts" -o app/models order.schema.json
```

writes `app/models/order.rb` starting with `module Acme; module
Contracts`.

## Positional names

Some schema sites have no name of their own:

- An inline object branch inside a `oneOf` on a value schema registers
  as `OneOf0`, `OneOf1`, numbered by position.
- An inline object entry inside `prefixItems` gets no class at all: a
  numeric position is not a constant name, and the element types as
  unconstrained.

## Output collisions

Before any file is written, the run checks that every generator and
every class lands on its own path. These fail with
`Schematrix::OutputCollisionError`, naming both claimants:

- Two input files with the same basename (`a.json` and `a.yaml`).
- Two generators that write the same schema site with the same file
  extension into one directory (for example, `plain_ruby` and
  `sorbet_ruby`). A data generator and an enum generator may share an
  extension and directory because they write different sites.
- Two schema sites whose folded class names collide, such as two
  `$defs` keys that normalize to one constant, or two keys where one
  is the hex fallback spelling of the other (`"@"` and `"40"`).

Output-path and enum member collisions abort before any files are
written. Give generators that claim the same paths separate `-o`
directories, or run them as separate commands.

A different, smaller clash stays a warning: two property names of one
class can fold onto one accessor (`"foo-bar"` and `"foo_bar"`). The
class still compiles, the first declaration wins, and the warning names
both. See [Generated code](generated-code.md).
