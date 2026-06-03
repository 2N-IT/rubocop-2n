# frozen_string_literal: true

RSpec.describe RuboCop::Cop::N2::BooleanColumnWithIsPrefix, :config do
  it 'flags add_column with is_ prefix on boolean column' do
    expect_offense(<<~RUBY)
      add_column :users, :is_active, :boolean
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `is_` prefix on boolean columns — use `active` instead of `is_active`.
    RUBY
  end

  it 'flags add_column with is_ prefix regardless of table name' do
    expect_offense(<<~RUBY)
      add_column :orders, :is_confirmed, :boolean
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `is_` prefix on boolean columns — use `confirmed` instead of `is_confirmed`.
    RUBY
  end

  it 'flags add_column with is_ prefix called on a receiver' do
    expect_offense(<<~RUBY)
      t.add_column :users, :is_verified, :boolean
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `is_` prefix on boolean columns — use `verified` instead of `is_verified`.
    RUBY
  end

  it 'does not flag add_column with is_ prefix on non-boolean column' do
    expect_no_offenses(<<~RUBY)
      add_column :users, :is_active, :string
    RUBY
  end

  it 'does not flag add_column without is_ prefix on boolean column' do
    expect_no_offenses(<<~RUBY)
      add_column :users, :active, :boolean
    RUBY
  end

  it 'does not flag add_column with column name that just contains is (not prefix)' do
    expect_no_offenses(<<~RUBY)
      add_column :users, :analysis, :boolean
    RUBY
  end

  it 'flags t.boolean with is_ prefix inside create_table' do
    expect_offense(<<~RUBY)
      create_table :cats do |t|
        t.boolean :is_worm
        ^^^^^^^^^^^^^^^^^^ Avoid `is_` prefix on boolean columns — use `worm` instead of `is_worm`.
      end
    RUBY
  end

  it 'flags t.boolean with is_ prefix called without a receiver' do
    expect_offense(<<~RUBY)
      boolean :is_active
      ^^^^^^^^^^^^^^^^^^ Avoid `is_` prefix on boolean columns — use `active` instead of `is_active`.
    RUBY
  end

  it 'does not flag t.boolean without is_ prefix' do
    expect_no_offenses(<<~RUBY)
      create_table :cats do |t|
        t.boolean :worm
      end
    RUBY
  end

  it 'does not flag t.string with is_ prefix (non-boolean type)' do
    expect_no_offenses(<<~RUBY)
      create_table :cats do |t|
        t.string :is_name
      end
    RUBY
  end
end
