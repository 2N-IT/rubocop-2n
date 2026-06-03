# frozen_string_literal: true

RSpec.describe RuboCop::Cop::N2::HashValueShorthand, :config do
  include_context 'ruby 3.1'

  it 'flags { name: name } where key matches local variable' do
    expect_offense(<<~RUBY)
      { name: name }
        ^^^^^^^^^^ Use Ruby 3.1 hash value shorthand `{ name: }` instead of `{ name: name }`.
    RUBY

    expect_correction(<<~RUBY)
      { name: }
    RUBY
  end

  it 'flags { user_id: user_id }' do
    expect_offense(<<~RUBY)
      { user_id: user_id }
        ^^^^^^^^^^^^^^^^ Use Ruby 3.1 hash value shorthand `{ user_id: }` instead of `{ user_id: user_id }`.
    RUBY

    expect_correction(<<~RUBY)
      { user_id: }
    RUBY
  end

  it 'does not flag { name: other }' do
    expect_no_offenses(<<~RUBY)
      { name: other }
    RUBY
  end

  it 'does not flag { name: obj.name } (method call on receiver)' do
    expect_no_offenses(<<~RUBY)
      { name: obj.name }
    RUBY
  end

  it 'does not flag { name: name(arg) } (method with arguments)' do
    expect_no_offenses(<<~RUBY)
      { name: name(arg) }
    RUBY
  end

  it 'does not flag { "name" => name } (string key)' do
    expect_no_offenses(<<~RUBY)
      { "name" => name }
    RUBY
  end

  it 'flags matching pair in multi-key hash, leaves non-matching alone' do
    expect_offense(<<~RUBY)
      { id: id, name: other }
        ^^^^^^ Use Ruby 3.1 hash value shorthand `{ id: }` instead of `{ id: id }`.
    RUBY

    expect_correction(<<~RUBY)
      { id:, name: other }
    RUBY
  end
end
