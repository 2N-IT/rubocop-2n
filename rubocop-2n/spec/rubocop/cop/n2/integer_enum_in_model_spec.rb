# frozen_string_literal: true

RSpec.describe RuboCop::Cop::N2::IntegerEnumInModel, :config do
  it 'flags modern form with integer values' do
    expect_offense(<<~RUBY)
      enum :status, { active: 0, inactive: 1 }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer string-backed enums `key: "key"` over integer-backed - safer in raw DB queries and immune to insertion-order bugs.
    RUBY
  end

  it 'flags legacy keyword form with integer values' do
    expect_offense(<<~RUBY)
      enum status: { active: 0, inactive: 1 }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer string-backed enums `key: "key"` over integer-backed - safer in raw DB queries and immune to insertion-order bugs.
    RUBY
  end

  it 'flags when only the first value is an integer' do
    expect_offense(<<~RUBY)
      enum :priority, { low: 0 }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer string-backed enums `key: "key"` over integer-backed - safer in raw DB queries and immune to insertion-order bugs.
    RUBY
  end

  it 'does not flag modern form with string values' do
    expect_no_offenses(<<~RUBY)
      enum :status, { active: "active", inactive: "inactive" }
    RUBY
  end

  it 'does not flag legacy keyword form with string values' do
    expect_no_offenses(<<~RUBY)
      enum status: { active: "active", inactive: "inactive" }
    RUBY
  end

  it 'does not flag enum with symbol values' do
    expect_no_offenses(<<~RUBY)
      enum :status, { active: :active, inactive: :inactive }
    RUBY
  end

  it 'flags modern form with symbol array (position-based integers)' do
    expect_offense(<<~RUBY)
      enum :status, %i[active inactive]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer string-backed enums `key: "key"` over integer-backed - safer in raw DB queries and immune to insertion-order bugs.
    RUBY
  end

  it 'flags modern form with symbol array and extra options' do
    expect_offense(<<~RUBY)
      enum :condition, [:new, :used_grade_1], prefix: :condition
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer string-backed enums `key: "key"` over integer-backed - safer in raw DB queries and immune to insertion-order bugs.
    RUBY
  end

  it 'flags modern form with string array (position still maps to integer)' do
    expect_offense(<<~RUBY)
      enum :status, %w[active inactive]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer string-backed enums `key: "key"` over integer-backed - safer in raw DB queries and immune to insertion-order bugs.
    RUBY
  end

  it 'flags legacy keyword form with symbol array' do
    expect_offense(<<~RUBY)
      enum status: %i[active inactive]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer string-backed enums `key: "key"` over integer-backed - safer in raw DB queries and immune to insertion-order bugs.
    RUBY
  end

  it 'flags legacy keyword form with string array' do
    expect_offense(<<~RUBY)
      enum status: %w[active inactive]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer string-backed enums `key: "key"` over integer-backed - safer in raw DB queries and immune to insertion-order bugs.
    RUBY
  end
end
