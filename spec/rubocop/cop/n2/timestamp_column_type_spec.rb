# frozen_string_literal: true

RSpec.describe RuboCop::Cop::N2::TimestampColumnType, :config do
  it 'flags t.datetime :created_at' do
    expect_offense(<<~RUBY)
      t.datetime :created_at
      ^^^^^^^^^^^^^^^^^^^^^^ Use `t.timestamps` instead of declaring `created_at` as a `datetime` column.
    RUBY
  end

  it 'flags t.datetime :updated_at' do
    expect_offense(<<~RUBY)
      t.datetime :updated_at
      ^^^^^^^^^^^^^^^^^^^^^^ Use `t.timestamps` instead of declaring `updated_at` as a `datetime` column.
    RUBY
  end

  it 'flags t.timestamp :created_at' do
    expect_offense(<<~RUBY)
      t.timestamp :created_at
      ^^^^^^^^^^^^^^^^^^^^^^^ Use `t.timestamps` instead of declaring `created_at` as a `timestamp` column.
    RUBY
  end

  it 'flags add_column :users, :updated_at, :datetime' do
    expect_offense(<<~RUBY)
      add_column :users, :updated_at, :datetime
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `t.timestamps` instead of declaring `updated_at` as a `datetime` column.
    RUBY
  end

  it 'does not flag t.timestamps' do
    expect_no_offenses(<<~RUBY)
      t.timestamps
    RUBY
  end

  it 'does not flag a non-timestamp datetime column' do
    expect_no_offenses(<<~RUBY)
      t.datetime :published_at
    RUBY
  end

  it 'does not flag a created_at column of another type' do
    expect_no_offenses(<<~RUBY)
      t.integer :created_at
    RUBY
  end
end
