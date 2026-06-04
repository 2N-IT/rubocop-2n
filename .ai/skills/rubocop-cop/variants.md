# Detecting every implementation of the same problem

A cop enforces a rule. The same rule is usually violated by code that *looks* different but *means* the same thing. Missing a variant is worse than not having the cop: it certifies bad code as clean.

This file is the methodology for finding and covering all variants.

## 1. Enumerate variant axes

For the violation you're targeting, walk these axes and write down each concrete form. Inspect the AST of each with `ruby-parse -e "..."` before writing matchers — variants that read similarly often parse very differently.

| Axis | Example forms of "the same thing" |
|---|---|
| **API version** | modern positional args vs legacy keyword/hash args |
| **Argument packaging** | positional vs keyword vs single options hash |
| **Collection literal** | `[:a, :b]` vs `%i[a b]` vs `%w[a b]` vs `Array(...)` |
| **Hash syntax** | `{ a: 1 }` vs `{ :a => 1 }` vs `{ "a" => 1 }` |
| **Receiver shape** | bare call `foo` vs `self.foo` vs `obj.foo` vs `obj&.foo` |
| **Block form** | `{ \|x\| }` vs `do \|x\| end` vs numbered `_1` vs `it` |
| **Value source** | literal vs local var vs method call vs constant |
| **Naming** | exact name vs prefix/suffix vs case variation |
| **Negation/inversion** | `unless x` vs `if !x`; `x.empty?` vs `x.size == 0` |
| **String vs symbol** | `:foo` vs `"foo"` as an argument or hash key |

Not every axis applies — but checking the list keeps you from shipping a half-covering cop.

## 2. Cover variants with multiple named matchers, OR'd together

The cleanest structure: one `def_node_matcher` per distinct AST shape, combined in the callback. Each matcher stays readable; adding a newly-discovered variant is a one-line addition.

```ruby
# Same rule ("don't use the integer-backed form"), four AST shapes.
def_node_matcher :modern_hash_form?, <<~PATTERN
  (send {nil? _} :enum (sym _) (hash (pair _ (int _)) ...) ...)
PATTERN

def_node_matcher :modern_array_form?, <<~PATTERN
  (send {nil? _} :enum (sym _) (array _ ...) ...)
PATTERN

def_node_matcher :legacy_hash_form?, <<~PATTERN
  (send {nil? _} :enum (hash (pair (sym _) (hash (pair _ (int _)) ...)) ...))
PATTERN

def_node_matcher :legacy_array_form?, <<~PATTERN
  (send {nil? _} :enum (hash (pair (sym _) (array _ ...)) ...))
PATTERN

def on_send(node)
  return unless modern_hash_form?(node) || modern_array_form?(node) ||
                legacy_hash_form?(node)  || legacy_array_form?(node)

  add_offense(node)
end
```

Prefer this over one giant pattern with deeply nested `{...}` alternations — the giant pattern becomes unreadable and silently stops matching when you tweak it.

When variants share a *fix* but differ in *where the relevant node lives*, give each matcher its own handler:

```ruby
def on_send(node)
  add_column_form?(node) { register_offense(node, node.arguments[1]) }
  builder_form?(node)    { register_offense(node, node.arguments[0]) }
end
```

## 3. Match by structure, not by element type

When you don't care about the *type* of a child, use `_`, not a typed node. This is the single most common way cops miss variants.

```
# Too narrow — only symbol-element arrays; misses %w[] and [1, 2]
(send _ :enum (sym _) (array (sym _) ...) ...)

# Correct — any array regardless of element type
(send _ :enum (sym _) (array _ ...) ...)
```

Same idea for receivers (`{nil? _}` covers bare *and* explicit-receiver calls) and for safe navigation (`{send csend}` or aliasing `on_csend`).

## 4. Fold fuzzy variants into predicate helpers

When a variant is "any name starting with `is_`" or "any ignored block arg", a static pattern can't express it. Call out to a Ruby predicate from inside the pattern with `#method`:

```ruby
def_node_matcher :boolean_with_is_prefix?, <<~PATTERN
  (send _ :boolean (sym #starts_with_is?) ...)
PATTERN

def starts_with_is?(name)
  name.to_s.start_with?("is_")
end
```

This collapses an unbounded family of names into one matcher. Same technique handles "value is a local var OR a bare method call" — match `$_` and then branch in Ruby on `lvar_type?` / `send_type?`.

## 5. Watch for looks-the-same-but-isn't (and vice versa)

Two traps when reasoning about variants:

- **Different syntax, same meaning** — must all be caught. `%w[a b]`, `%i[a b]`, and `[:a, :b]` passed to a position-based API all mean the same thing to the framework even though one "looks like strings."
- **Same syntax, different meaning** — must NOT be lumped together. `{ active: "active" }` (hash form) and `%w[active]` (array form) look related but one stores a string and the other stores a position-integer. Verify against the framework's source, not the surface syntax, before deciding two forms are equivalent.

## 6. Prove coverage in the spec

Every variant you claim to cover needs its own `expect_offense` example, and every near-miss that must stay legal needs an `expect_no_offenses`. The spec is where "I think I covered them all" becomes "I did."

```ruby
it 'flags the modern hash form'  do expect_offense(...) end
it 'flags the legacy hash form'  do expect_offense(...) end
it 'flags the %i[] array form'   do expect_offense(...) end
it 'flags the %w[] array form'   do expect_offense(...) end
it 'ignores the correct form'    do expect_no_offenses(...) end
```

If you add a variant matcher later, add its spec example in the same change.

## Checklist before declaring a cop done

- [ ] Listed every variant axis that applies; inspected each form's AST
- [ ] One matcher (or predicate) per distinct shape, OR'd in the callback
- [ ] Used `_` for don't-care children instead of typed nodes
- [ ] Handled receiver shapes and safe navigation (`{nil? _}`, `on_csend`)
- [ ] Confirmed which look-alike forms are genuinely the same rule and which aren't
- [ ] One spec example per covered variant + at least one no-offense near-miss
