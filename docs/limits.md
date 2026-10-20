# Limits and approximations

Schematrix generates data shapes, not validators. This page states what
the output does not do, and where it accepts more than the schema
requires. The design rule is one direction only: the output never
rejects data the schema accepts.

## No validation

Constraint keywords never reach the output. Generated classes check no
`pattern`, `minimum`, `maxLength`, `format`, `multipleOf`, or similar.
`from_h` accepts a hash that violates the schema and builds an instance
from it. Validate data separately when you need to.

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
their absence from the list above is expected: `default` and
`description` do reach the output, the rest do not.

## Accepted approximations

Each item below widens acceptance. None of them narrows it.

- A `false` branch inside `allOf` is skipped. Strictly the schema is
  then uninhabitable; the output behaves as if the branch were absent.
- A union of distinct `$ref` targets on one property keeps the first
  target's class for loading and dumping. Other targets' classes still
  generate.
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
  on load, not on dump.
- Type names inside RBS and RBI signatures are relative
  (`Schema::Props::Child`, not `MyApp::Schema::Props::Child`), which
  resolves lexically. A schema whose property names shadow an enclosing
  class name could bind the wrong constant. Property coercion in
  generated loading code is fully qualified and unaffected.

## Signatures are shapes, not proofs

The Sorbet and RBS output types every slot, including slots the schema
left unconstrained: those render as `T.anything` or `top`. Reads from
such a slot need narrowing before the type checker accepts them. That
is the honest statement about data whose shape the schema does not
constrain.
