# frozen_string_literal: true

require 'rubocop'
require 'rubocop/rspec/expect_offense'
require 'rubocop/rspec/support'
require_relative '../../../../lib/rubocop/cop/n2/before_action_set_x'

RSpec.describe RuboCop::Cop::N2::BeforeActionSetX, :config do
  include RuboCop::RSpec::ExpectOffense

  it 'flags before_action :set_user' do
    expect_offense(<<~RUBY)
      before_action :set_user
      ^^^^^^^^^^^^^^^^^^^^^^^ Avoid `before_action :set_user` — prefer a memoized `def user` called directly in each action.
    RUBY
  end

  it 'flags before_action :set_order with only: option' do
    expect_offense(<<~RUBY)
      before_action :set_order, only: %i[show edit update destroy]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `before_action :set_order` — prefer a memoized `def order` called directly in each action.
    RUBY
  end

  it 'flags before_action :set_product with multiple actions' do
    expect_offense(<<~RUBY)
      before_action :set_product, only: [:show]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `before_action :set_product` — prefer a memoized `def product` called directly in each action.
    RUBY
  end

  it 'does not flag before_action with a non-set_ method' do
    expect_no_offenses(<<~RUBY)
      before_action :authenticate_user!
    RUBY
  end

  it 'does not flag before_action :setup_something (starts with set but not set_)' do
    expect_no_offenses(<<~RUBY)
      before_action :setup_wizard
    RUBY
  end

  it 'does not flag after_action :set_user' do
    expect_no_offenses(<<~RUBY)
      after_action :set_user
    RUBY
  end
end
