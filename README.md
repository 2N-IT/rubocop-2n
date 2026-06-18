# rubocop-2n

Custom RuboCop cops for the 2N organisation.

## Installation

Add to your `Gemfile`:

```ruby
gem 'rubocop-2n', github: '2N-IT/rubocop-2n', require: false
```

Then run:

```bash
bundle install
```

## Configuration

Copy the default config into your project:

```bash
curl -o .rubocop_2n.yml https://raw.githubusercontent.com/2N-IT/rubocop-2n/main/config/default.yml
```

## Running

```bash
bundle exec rubocop -c .rubocop_2n.yml
```
