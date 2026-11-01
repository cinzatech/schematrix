# Enum serialization spike

Sorbet runtime 0.6.13583 accepts integer serialized values in `T::Enum`.
An enum with `One = new(1)` and `Two = new(2)` passed these checks:

- `deserialize(1)` returns the same object as `One`.
- `Two.serialize` returns the integer `2`.
- The enum and a bidirectional `coerce` method pass strict type checking.

The check used Ruby 3.4.6 and the Sorbet static binary directly. The
`srb` wrapper loaded an unrelated installed Prism RBI with an unresolved
`Prism::LexCompat` constant.

Tapioca 0.20.0's `SorbetEnums` listener emits member declarations inside
an `RBI::TEnumBlock`. Rendering its tree produces this shape:

```ruby
class IntegerEnumSpike < T::Enum
  enums do
    One = new
    Two = new
  end
end
```

No integer serialization fallback is needed. Member names that start
with digits use the resolver's `N` prefix. An underscore prefix would
not form a valid Ruby constant.

## Member name equal to the class name

Sorbet cannot type a member whose constant name equals its enclosing
enum class's leaf name. The problematic shape is:

```ruby
class Affiliation < T::Enum
  enums do
    Affiliation = new("affiliation")
    External = new("external")
  end
end
```

The inner `Affiliation` denotes a member, not a type. Qualifying type
references does not make this member declaration usable by Sorbet.
The chosen limit is to reject this shape in `sorbet_ruby_enums` and
`rbi_enums` with `Schematrix::OutputCollisionError`. The check compares
the folded member name with the enclosing class leaf, so it also
applies to nested classes and differently spelled values that fold to
that name. Plain Ruby and RBS permit it.

This restriction is separate from namespace shadowing in consumers.
Partial and DSL signatures use absolute class references to select
the shared enum class outside their `Partial` and `Dsl` namespaces.
They do not create another enum family.
