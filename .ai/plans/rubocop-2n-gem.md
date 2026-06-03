# Plan: Build rubocop-2n gem

## Goal

Create a standalone `rubocop-2n` gem that packages all existing custom cops (migrated from
the `asdf/` prototype), using `N2` as the Ruby namespace and `N2/` as the RuboCop department,
with a `lint_roller` Plugin for clean integration and RubydexContext stubbed for future
cross-file cops.

---

## Namespace decisions

- Ruby module: `RuboCop::Cop::N2` — valid constant, matches existing files
- RuboCop department in YAML: `N2/` (e.g. `N2/BooleanColumnWithIsPrefix`)
- Gem name: `rubocop-2n` (gem names don't need to be valid constants)
- Plugin integration: `lint_roller` — the current blessed RuboCop plugin API, already a
  dependency of RuboCop itself; replaces the fragile `ConfigLoader` mutation approach
- Test framework: RSpec — RuboCop's `ExpectOffense` DSL is RSpec-only; no migration needed

---

## Files to read (reference only)

- `asdf/.rubocop-custom.yml` — cop config, Include filters, enabled/disabled defaults
- `asdf/rubocop/cop/n2/*.rb` — 7 existing cop implementations
- `asdf/rubocop_1/cop/n2/*_spec.rb` — 7 existing RSpec files to migrate

---

## Files to create

### Gem skeleton

| File | Purpose |
|------|---------|
| `rubocop-2n/rubocop-2n.gemspec` | Gem definition; depends on `rubocop >= 1.50`, `lint_roller`; sets `default_lint_roller_plugin` metadata |
| `rubocop-2n/Gemfile` | Development dependencies (rspec, rubocop for tests) |
| `rubocop-2n/lib/rubocop-2n.rb` | Entry point: requires all pieces (no manual `Inject` call needed) |
| `rubocop-2n/lib/rubocop_2n/version.rb` | `RuboCop::N2::VERSION = "0.1.0"` |
| `rubocop-2n/lib/rubocop_2n/plugin.rb` | `RuboCop::N2::Plugin < LintRoller::Plugin` — implements `about` and `rules` pointing at `config/default.yml` |
| `rubocop-2n/lib/rubocop_2n/rubydex_context.rb` | Lazy `@graph ||= Rubydex::Graph.build(Dir.pwd)`; stubbed until gem is needed |
| `rubocop-2n/lib/rubocop/cop/n2.rb` | Requires all 7 cop files |
| `rubocop-2n/config/default.yml` | Cop config ported from `.rubocop-custom.yml`; department already `N2/` |

### Plugin class shape

```ruby
module RuboCop
  module N2
    class Plugin < LintRoller::Plugin
      def about
        LintRoller::About.new(
          name: "rubocop-2n",
          version: VERSION,
          homepage: "",
          description: "2N organisation RuboCop cops"
        )
      end

      def supported?(context)
        context.engine == :rubocop
      end

      def rules(context)
        LintRoller::Rules.new(
          type: :path,
          config_format: :rubocop,
          value: Pathname.new(__dir__).join("../../..", "config", "default.yml")
        )
      end
    end
  end
end
```

### Gemspec metadata (replaces manual require in `.rubocop.yml`)

```ruby
spec.metadata["default_lint_roller_plugin"] = "RuboCop::N2::Plugin"
```

### User configuration (how projects consume the gem)

```yaml
# .rubocop.yml
plugins:
  - rubocop-2n
```

No `require:` block needed — RuboCop discovers the plugin via gemspec metadata.

---

### Cops (copied from `asdf/rubocop/cop/n2/`, no changes needed)

| Source | Destination |
|--------|-------------|
| `asdf/rubocop/cop/n2/before_action_set_x.rb` | `rubocop-2n/lib/rubocop/cop/n2/before_action_set_x.rb` |
| `asdf/rubocop/cop/n2/boolean_column_with_is_prefix.rb` | `rubocop-2n/lib/rubocop/cop/n2/boolean_column_with_is_prefix.rb` |
| `asdf/rubocop/cop/n2/hash_value_shorthand.rb` | `rubocop-2n/lib/rubocop/cop/n2/hash_value_shorthand.rb` |
| `asdf/rubocop/cop/n2/integer_enum_in_model.rb` | `rubocop-2n/lib/rubocop/cop/n2/integer_enum_in_model.rb` |
| `asdf/rubocop/cop/n2/map_to_values.rb` | `rubocop-2n/lib/rubocop/cop/n2/map_to_values.rb` |
| `asdf/rubocop/cop/n2/memoization_missing_in_finder.rb` | `rubocop-2n/lib/rubocop/cop/n2/memoization_missing_in_finder.rb` |
| `asdf/rubocop/cop/n2/policy_scope_missing_in_finder.rb` | `rubocop-2n/lib/rubocop/cop/n2/policy_scope_missing_in_finder.rb` |

### Specs (migrated from `asdf/rubocop_1/cop/n2/`, require path updated only)

| Source | Destination | Change |
|--------|-------------|--------|
| `asdf/rubocop_1/cop/n2/before_action_set_x_spec.rb` | `rubocop-2n/spec/rubocop/cop/n2/before_action_set_x_spec.rb` | update `require_relative` path |
| `asdf/rubocop_1/cop/n2/boolean_column_with_is_prefix_spec.rb` | `rubocop-2n/spec/rubocop/cop/n2/boolean_column_with_is_prefix_spec.rb` | update `require_relative` path |
| `asdf/rubocop_1/cop/n2/hash_value_shorthand_spec.rb` | `rubocop-2n/spec/rubocop/cop/n2/hash_value_shorthand_spec.rb` | update `require_relative` path |
| `asdf/rubocop_1/cop/n2/integer_enum_in_model_spec.rb` | `rubocop-2n/spec/rubocop/cop/n2/integer_enum_in_model_spec.rb` | update `require_relative` path |
| `asdf/rubocop_1/cop/n2/map_to_values_spec.rb` | `rubocop-2n/spec/rubocop/cop/n2/map_to_values_spec.rb` | update `require_relative` path |
| `asdf/rubocop_1/cop/n2/memoization_missing_in_finder_spec.rb` | `rubocop-2n/spec/rubocop/cop/n2/memoization_missing_in_finder_spec.rb` | update `require_relative` path |
| `asdf/rubocop_1/cop/n2/policy_scope_missing_in_finder_spec.rb` | `rubocop-2n/spec/rubocop/cop/n2/policy_scope_missing_in_finder_spec.rb` | update `require_relative` path |

Also create `rubocop-2n/spec/spec_helper.rb`.

---

## Steps

1. **Create directory tree** — `rubocop-2n/` with subdirs: `lib/rubocop_2n/`, `lib/rubocop/cop/n2/`, `config/`, `spec/rubocop/cop/n2/`.

2. **Write `version.rb`** — `RuboCop::N2::VERSION = "0.1.0"`.

3. **Write `plugin.rb`** — `RuboCop::N2::Plugin < LintRoller::Plugin` with `about`, `supported?`, and `rules` returning a path to `config/default.yml`.

4. **Write `rubydex_context.rb`** — module with `self.graph` lazy-initialising via `||=`. Does NOT `require 'rubydex'` at load time (only inside `graph`), so the gem loads cleanly before rubydex is added.

5. **Write `config/default.yml`** — port directly from `asdf/.rubocop-custom.yml`. Department prefix is already `N2/`, no renaming needed. Remove the `require:` block (handled by the gem). Keep `AllCops`, `Include:` filters, and enabled/disabled states.

6. **Copy all 7 cop files** verbatim from `asdf/rubocop/cop/n2/` to `rubocop-2n/lib/rubocop/cop/n2/`.

7. **Write `lib/rubocop/cop/n2.rb`** — `require_relative` each of the 7 cops.

8. **Write `lib/rubocop-2n.rb`** — require lint_roller, rubocop, version, plugin, cop index. No `Inject` call.

9. **Write `rubocop-2n.gemspec`** — add `lint_roller` dependency, set `spec.metadata["default_lint_roller_plugin"] = "RuboCop::N2::Plugin"`.

10. **Write `Gemfile`**.

11. **Write `spec/spec_helper.rb`** — require rubocop, rspec helpers, rubocop-2n entry point.

12. **Migrate 7 spec files** — copy from `asdf/rubocop_1/cop/n2/`, update only the `require_relative` line to point to the new lib path (`../../../../lib/rubocop/cop/n2/<cop_name>`). All test logic stays identical.

13. **Verify** — `cd rubocop-2n && bundle install && bundle exec rspec` should be green.

---

## Risks

- **`lint_roller` version** — `Plugin#rules` API is stable but check the installed RuboCop version ships with lint_roller; if the project targets RuboCop < 1.65 (when lint_roller was adopted), fall back to the `require:` approach.
- **`RubydexContext` stub** — must not `require 'rubydex'` at the top level or the gem will fail to load in projects that don't have rubydex installed.
- **`HashValueShorthand` Ruby version** — requires `include_context 'ruby 3.1'` in its spec (already present). The cop is `Enabled: false` by default in the config, which is correct.
- **`require_relative` depth** — specs live at `spec/rubocop/cop/n2/`, cops at `lib/rubocop/cop/n2/`, so the relative path is `../../../../lib/rubocop/cop/n2/<name>`. Verify depth is correct for each file.
