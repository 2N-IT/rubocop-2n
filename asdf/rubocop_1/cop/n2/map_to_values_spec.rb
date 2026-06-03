# frozen_string_literal: true

require 'rubocop'
require 'rubocop/rspec/expect_offense'
require 'rubocop/rspec/support'
require_relative '../../../../lib/rubocop/cop/n2/map_to_values'

RSpec.describe RuboCop::Cop::N2::MapToValues, :config do
  include RuboCop::RSpec::ExpectOffense

  it 'flags .map { |_k, v| v } with underscore-prefixed ignored key' do
    expect_offense(<<~RUBY)
      hash.map { |_k, v| v }
      ^^^^^^^^^^^^^^^^^^^^^^ Use `hash.values` instead of `.map { |_, v| v }`.
    RUBY

    expect_correction(<<~RUBY)
      hash.values
    RUBY
  end

  it 'flags .map { |_, v| v } with bare underscore ignored key' do
    expect_offense(<<~RUBY)
      hash.map { |_, v| v }
      ^^^^^^^^^^^^^^^^^^^^^ Use `hash.values` instead of `.map { |_, v| v }`.
    RUBY

    expect_correction(<<~RUBY)
      hash.values
    RUBY
  end

  it 'flags .map { |_key, value| value } with longer names' do
    expect_offense(<<~RUBY)
      hash.map { |_key, value| value }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `hash.values` instead of `.map { |_, v| v }`.
    RUBY

    expect_correction(<<~RUBY)
      hash.values
    RUBY
  end

  it 'does not flag .map { |k, v| v } when key is not ignored' do
    expect_no_offenses(<<~RUBY)
      hash.map { |k, v| v }
    RUBY
  end

  it 'does not flag .map { |_k, v| k }  when body returns the key' do
    expect_no_offenses(<<~RUBY)
      hash.map { |_k, v| _k }
    RUBY
  end

  it 'does not flag .map { |_k, v| v.upcase } when body transforms the value' do
    expect_no_offenses(<<~RUBY)
      hash.map { |_k, v| v.upcase }
    RUBY
  end

  it 'does not flag .map { |v| v } (single-param block)' do
    expect_no_offenses(<<~RUBY)
      array.map { |v| v }
    RUBY
  end
end
