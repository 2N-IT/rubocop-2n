---
name: rubocop-cop
description: Create, scaffold, or explain custom RuboCop cops. Use when the user wants to write a custom RuboCop cop, add autocorrection to a cop, write NodePattern matchers, test cops with RSpec, or understand RuboCop cop internals.
argument-hint: "[cop name or description of what to enforce]"
allowed-tools: Read, Edit, Write, Bash
---

You are an expert at writing custom RuboCop cops. When given a cop name or description, generate a complete, working cop.

## Core principle: one problem, every implementation

A cop enforces a *rule*, not a *syntax*. The same logical violation almost always has several syntactic forms, and a cop that catches only the form you first thought of gives **false confidence** — code passes lint while still violating the rule.

Before writing any matcher, enumerate every way the bad pattern can be written, then make sure each one is covered. See [variants.md](variants.md) for the full methodology: the variant-axis checklist, how to combine multiple matchers, and how to write structural (not type-specific) patterns.

## Cop skeleton

```ruby
# frozen_string_literal: true

module RuboCop
  module Cop
    module <Department>
      # Enforces <what it checks>. <One sentence, starts with verb, ends with period.>
      #
      # @example
      #   # bad
      #   <bad code>
      #
      #   # good
      #   <good code>
      class <CopName> < Base
        extend AutoCorrector  # omit if no autocorrect

        MSG = '<offense message>'

        # RESTRICT_ON_SEND = %i[method_name].freeze  # uncomment to limit send callbacks

        def_node_matcher :offensive_pattern?, <<~PATTERN
          # NodePattern here
        PATTERN

        def on_send(node)
          offensive_pattern?(node) do |*captures|
            add_offense(node) do |corrector|
              corrector.replace(node, corrected_source(captures))
            end
          end
        end
        alias on_csend on_send  # handles &. safe navigation

        private

        def corrected_source(captures)
          # return corrected string
        end
      end
    end
  end
end
```

## Key rules

- Inherit from `RuboCop::Cop::Base` (not legacy `Cop`)
- `extend AutoCorrector` only when providing fixes
- `MSG` constant holds the offense message
- Callback methods: `on_send`, `on_def`, `on_class`, `on_block`, `on_lvar`, etc. — one per AST node type
- Alias `on_csend` → `on_send` to catch safe-navigation calls
- Alias `on_numblock` and `on_itblock` → `on_block` to catch numbered/it params
- `RESTRICT_ON_SEND` limits which method names trigger `on_send` — always set it when you know the method name

## NodePattern cheatsheet

| Pattern | Matches |
|---|---|
| `(send nil? :foo)` | bare `foo` call |
| `(send _ :foo)` | `anything.foo` |
| `(send $_ :foo)` | captures receiver |
| `(send _ :foo ...)` | `foo` with any args |
| `(send _ :foo $_)` | captures single arg |
| `{send csend}` | send or csend |
| `[send? csend?]` | send AND csend node |
| `#offensive?` | calls `offensive?` method |

### Declaration helpers

```ruby
def_node_matcher :name?, pattern          # returns truthy/nil
def_node_matcher :name, pattern           # returns capture or nil
def_node_search :find_all, pattern        # enumerator of matches in subtree
def_node_search :find_first, pattern      # first match or nil
```

### Pattern syntax

```
(node_type child1 child2 ...)   exact node with children
(node_type ...)                 node with any children
_          any single node
...        any number of nodes (sequence wildcard)
$_         capture any single node
$(...)     capture matched subpattern
{a b c}    matches any of a, b, c (OR)
[a b c]    matches all of a, b, c (AND)
!pattern   does NOT match pattern
#method    calls cop method `method?` on node
(send _ :foo _?)   optional last child
(send _ :foo _*)   zero or more
(send _ :foo _+)   one or more
```

### Common AST node types

| Ruby code | Node type |
|---|---|
| `foo.bar` | `(send (send nil? :foo) :bar)` |
| `foo&.bar` | `(csend ...)` |
| `@foo` | `(ivar :@foo)` |
| `@foo = x` | `(ivasgn :@foo x)` |
| `@foo \|\|= x` | `(or-asgn (ivasgn :@foo) x)` |
| `Foo::Bar` | `(const (const nil? :Foo) :Bar)` |
| `def foo` | `(def :foo (args) body)` |
| `x = 1` | `(lvasgn :x (int 1))` |

## Node accessor gotchas

```ruby
node.children[1]      # RHS of ivasgn / or-asgn (the assigned value)
node.receiver         # receiver of a send node
node.method_name      # method name of a send node
node.arguments        # arguments of a send node
node.loc.operator     # operator token (e.g. `=` in ivasgn — useful to replace with `||=`)
```

`node.value` does **not** exist on `ivasgn`/`or-asgn` nodes — use `node.children[1]` instead.

## Walking ancestors

```ruby
node.each_ancestor(:def).any? { |def_node| def_node.method_name == :create }
```

Useful for checking context (e.g. "is this assignment inside a method named `create`?").

## Walking receiver chains

Find the root constant of a chain (`User.includes(:x).find` → `User`):

```ruby
def receiver_root(node)
  return node unless node.respond_to?(:receiver) && node.receiver
  receiver_root(node.receiver)
end
```

Check if a specific method appears anywhere in a receiver chain:

```ruby
def wrapped_by_scope?(node, method)
  return false if node.nil?
  return true if node.send_type? && node.method_name == method
  wrapped_by_scope?(node.receiver, method) if node.respond_to?(:receiver)
end
```

## Dynamic offense messages

Use `format` with named keys to embed actual code in messages:

```ruby
MSG = "Prefer `foo` — e.g. `%<suggestion>s`."

add_offense(node, message: format(MSG, suggestion: build_suggestion(node)))
```

## Corrector methods

```ruby
corrector.replace(node, "new_source")
corrector.replace(node.loc.operator, '||=')  # replace just the operator token
corrector.insert_before(node, "prefix")
corrector.insert_after(node, "suffix")
corrector.wrap(node, "before", "after")
corrector.remove(node)
```

Use `node.source` to get original source text of a node.

## When NOT to autocorrect

Leave as warning-only if fixing requires:
- Removing a method definition
- Updating all call sites of that method
- Injecting code into multiple other methods

The risk of silent behavioral breakage outweighs the convenience.

## add_offense options

```ruby
add_offense(node)
add_offense(node, message: 'custom msg')
add_offense(node, severity: :warning)   # or :error, :fatal, :convention, :refactor
add_offense(node, location: :selector)  # highlight just method name
add_offense(node.loc.keyword)           # highlight keyword range
```

## Configuration

Access `.rubocop.yml` cop config:
```ruby
cop_config['MyKey']  # returns value or nil
```

## RSpec test structure

```ruby
# frozen_string_literal: true

require 'rubocop'
require 'rubocop/rspec/expect_offense'
require 'rubocop/rspec/support'
require_relative '../../../../lib/rubocop/cop/<department>/<cop_name>'

RSpec.describe RuboCop::Cop::<Department>::<CopName>, :config do
  include RuboCop::RSpec::ExpectOffense

  it 'flags the bad pattern' do
    expect_offense(<<~RUBY)
      bad_code_here
      ^^^^^^^^^^^^^ Offense message text
    RUBY
  end

  it 'autocorrects bad pattern' do
    expect_offense(<<~RUBY)
      bad_code_here
      ^^^^^^^^^^^^^ Offense message text
    RUBY
    expect_correction(<<~RUBY)
      good_code_here
    RUBY
  end

  it 'does not flag the good pattern' do
    expect_no_offenses(<<~RUBY)
      good_code_here
    RUBY
  end
end
```

- Use `:config` metadata on `RSpec.describe` — NOT `let(:config) { RuboCop::Config.new }` (that's legacy)
- `^` underline must exactly align with the width of the flagged source — AST node boundaries can be surprising (e.g. `ivasgn` does not include the closing `)` of its RHS). **Don't count manually — run the spec and read the diff**, it shows the exact expected width
- `expect_correction` always follows `expect_offense`, not standalone
- Test edge cases: safe navigation (`&.`), numbered params (`_1`), multiline

## Workflow when given a cop to build

1. Identify the bad pattern and what the fix/good pattern looks like
2. **Enumerate every implementation of the same violation** — walk the variant-axis checklist in [variants.md](variants.md) and inspect each form's AST with `ruby-parse` before writing matchers. A cop that misses half the ways to write something certifies bad code as clean.
3. Determine the AST node type (use `rubocop --debug` or `ruby-parse` to inspect AST)
4. Write the NodePattern to match the bad pattern
5. Decide if autocorrection is safe (pure rename → yes; semantic change → maybe not)
6. Write the cop class
7. Write RSpec tests covering: offense detected, correction applied, no false positives
8. Add to `.rubocop.yml` under the right department

## Covering all variants of the same problem

The hardest part of a cop is catching *every* form of one violation, not just the first you thought of. This is its own topic — see [variants.md](variants.md) for the variant-axis checklist, the multi-matcher pattern, structural-vs-typed matching (`_` over `(sym _)`), predicate helpers for fuzzy variants, and the look-alike traps (different syntax / same meaning, and same syntax / different meaning).

## Checking AST of code

```bash
ruby-parse -e "your_code_here"
# or
bundle exec rubocop --only Department/CopName --debug file.rb
```
