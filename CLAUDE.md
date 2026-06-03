# CLAUDE.md

## Commands

```bash
bundle exec rspec       # run all specs
bundle exec rspec spec/rubocop/cop/n2/map_to_values_spec.rb  # run a single spec
```

## Architecture

This is the `rubocop-2n` gem — a private RuboCop extension for the 2N organisation, integrated via the `lint_roller` plugin API.

**Load path:**
1. `lib/rubocop-2n.rb` — entry point; requires lint_roller, rubocop, then all internal pieces
2. `lib/rubocop_2n/plugin.rb` — `RuboCop::N2::Plugin < LintRoller::Plugin`; points RuboCop at `config/default.yml`
3. `lib/rubocop_2n/rubydex_context.rb` — lazy singleton that builds a `Rubydex::Graph` for cross-file analysis; `require 'rubydex'` is deferred inside `#graph` so the gem loads in projects without rubydex
4. `lib/rubocop/cop/n2.rb` — requires all cop files
5. `lib/rubocop/cop/n2/cop_base.rb` — `RuboCop::Cop::N2::CopBase < RuboCop::Cop::Base`; exposes `#graph` to any cop that needs cross-file reasoning

**Cops** live in `lib/rubocop/cop/n2/`. Inherit from `CopBase` when cross-file graph access is needed; otherwise inherit directly from `RuboCop::Cop::Base`.

**Config** in `config/default.yml`: `DisabledByDefault: true`, so each cop must be explicitly `Enabled: true`. File-scoped cops use `Include:` patterns (e.g. migrations, models, controllers).

**Tests** use RuboCop's `ExpectOffense` DSL (`RuboCop::RSpec::ExpectOffense`). Specs mirror the lib path under `spec/rubocop/cop/n2/`.
