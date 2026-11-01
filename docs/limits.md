# Limits and approximations

Schematrix generates data shapes, not validators. This page states what
the output does not do, and where it accepts more than the schema
requires. Shape compilation widens unsupported constraints. Format
conversion can reject schema-valid data, and enum conversion rejects
unknown members as described below.

## No validation

Constraint keywords never reach the output. Generated classes check no
`pattern`, `minimum`, `maxLength`, `multipleOf`, or similar. `from_h`
accepts a hash that violates the schema and builds an instance from
it. Validate data separately when you need to.

## Format conversion

`format` is the one annotation that reaches the output. For the scalar
formats the scalar type table maps (`date`, `date-time`, and whatever
the project adds through `scalar_types:`), every slot the type algebra
renders from a mapped format converts on load and dump: plain scalar
properties, array elements and tuple positions, map and catch-all
values, and branches of a union. The conversion can fail where the
schema does not: a string the coercer cannot parse raises from
`from_h` (`Date::Error`, `ArgumentError`, or whatever the coercer
raises). The spec reads `format` as an annotation, so a document with
an unparseable date string is valid; loading it into a generated class
is not. Validate documents before loading when that distinction
matters.

One shape cannot convert: a union whose branches would convert the
same JSON type through different coercers, such as `anyOf` of `date`
and `date-time`. A loaded value carries no mark of the branch it came
from, so rendering either branch's type alone would name loaded
values the other branch never produces. Generation fails with
`CoercionConflictError` instead. Give the branches distinct JSON
types, or map them to one coercer.

## Enums

Only enums with more than one distinct non-null value, all strings or
all integers, qualify. Mixed, single-value, boolean, and float enums,
and `const`, stay scalar. Null is a nullable slot term, not a member.
In `:unions` mode, Sorbet uses scalar types because it cannot spell
string or integer literal unions; RBS uses literal unions.

In `:classes` mode, standalone enum conversion raises `KeyError` for
an unknown raw value. Values of other Ruby types still pass through.
This is a conversion contract, not a general schema validator. A
coercing format entry wins conversion while the signature stays the
enum class; the generator does not enforce that the coercer returns a
member.

When enum union branches share a JSON type with another enum or an
uncoerced branch, the helper tries conversion and rescues `KeyError`.
A trailing `:pass` keeps values that no enum accepts. This can accept
values outside every schema branch. The first identity-changing result
wins; dumped strings are not fed through later enum conversions.
An enum and a builtin coercer claiming the same JSON type, such as a
string enum unioned with `format: "date"`, raise
`CoercionConflictError` during generation.

Distinct values that fold to the same member constant raise
`OutputCollisionError`. The Sorbet Ruby and RBI enum generators also
raise it when a folded member equals the enclosing class leaf, such as
`Affiliation::Affiliation`. Plain Ruby and RBS permit that name. See
[Enum serialization spike](enum-spike.md) for the Sorbet evidence.
The pipeline checks these names before writing any files.

Class usage without an enum writer only warns. The run succeeds but
the application must supply the constants. DSL and partial generators
never write enum files.

## Ignored keywords

These keywords are skipped, and each skip is logged once per document
at debug level:

- `not`
- `unevaluatedProperties`, `unevaluatedItems`
- `contains`, `minContains`, `maxContains`
- `dependentRequired`
- `patternProperties`, `propertyNames`

Skipping them keeps shapes open: extra keys land in the catch-all where
one exists.

`format`, `examples`, `default`, `title`, `description`, and
`deprecated` are annotations or constraints with no output effect, so
their absence from the list above is expected: `default`, `description`,
and mapped `format` values do reach the output, the rest do not.

## Accepted approximations

Each item below widens acceptance. None of them narrows it.

- A `false` branch inside `allOf` is skipped. Strictly the schema is
  then uninhabitable; the output behaves as if the branch were absent.
- A union of distinct `$ref` targets on one property keeps the first
  target's class for loading and dumping. Other targets' classes still
  generate. An `allOf` of distinct `$ref` targets on a value schema
  keeps the first the same way.
- An object shape that reaches a value-level `allOf` branch only
  through a nested composition keyword contributes no properties to
  the slot's class; its nested classes still generate under the
  branch's positional path.
- Fully disjoint `allOf` type declarations conjoin syntactically
  (`String & Integer`), which is uninhabited when the types share no
  value; the output behaves as if the branch were absent.
- Inline object entries inside `prefixItems` contribute an
  unconstrained element type, because a numeric position is not a class
  name.
- A `$dynamicRef` nested inside inlined content from a scalar `$ref`
  target is dropped, and its slot types as unconstrained.
- `unevaluatedProperties: false` does not close a shape. Use explicit
  `additionalProperties: false`, or `--closed-shapes`.
- A closed tuple's exact length has no rendering in Ruby type systems;
  the generated signature constrains element types only.
- A keyword whose value equals the schema's declared default is
  indistinguishable from an absent keyword, and both compile the same.
  `{"const": null}` on a slot types as unconstrained, not null-only,
  for the same reason.
- An optional slot dumped with `to_h` that was never set contributes
  nothing; but a slot with a schema default that was set to `nil`
  explicitly is also omitted. Absent and explicit `nil` stay distinct
  on load, not on dump. The `optionals: :maybe` mode closes this gap
  for every slot it wraps: absent stays absent and null stays null
  through dump.
- Data-class type names inside RBS and RBI signatures are generally relative
  (`Schema::Props::Child`, not `MyApp::Schema::Props::Child`), which
  resolves lexically. A schema whose property names shadow an enclosing
  class name could bind the wrong constant. Property coercion in
  generated loading code is fully qualified and unaffected. Enum
  references in partial and DSL signatures are absolute, so they
  cannot bind to a class in those families.

## Signatures are shapes, not proofs

The Sorbet and RBS output types every slot, including slots the schema
left unconstrained: those render as `T.anything` or `top`. Reads from
such a slot need narrowing before the type checker accepts them. That
is the honest statement about data whose shape the schema does not
constrain.

## Builders

The instance DSL builders ([The instance DSL](dsl.md)) inherit every
approximation above and add their own:

- A builder writes what its source declared and nothing else. `default`
  never materializes at build time, and `required` is never enforced.
- Where several variants of a union carry object classes, the block
  form builds through the first one, matching the data classes' first
  class term.
- Tuples feed the array setter positionally; deeper array nesting has
  no dedicated spelling and rides Array literals.
- Class-mode enum signatures accept members only. Raw strings or
  integers pass through the setter body, but do not satisfy the member
  type and fail static checking. Members serialize on store, including
  array elements and map values. See [The instance DSL](dsl.md).
