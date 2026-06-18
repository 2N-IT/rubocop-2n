# rubocop-2n

Custom RuboCop cops for the 2N organisation.

## Installation

Add to your `Gemfile`:

```ruby
gem "rubocop-2n", git: "git@github.com:2N-IT/rubocop-2n.git", require: false
```

Then run:

```bash
bundle install
```

## Configuration

Copy the default config into your project and prepend the `plugins:` declaration:

```bash
{ echo $'plugins:\n  - rubocop-2n\n'; cat $(bundle show rubocop-2n)/config/default.yml; } > .rubocop_2n.yml
```

## Running

```bash
bundle exec rubocop -c .rubocop_2n.yml
```
