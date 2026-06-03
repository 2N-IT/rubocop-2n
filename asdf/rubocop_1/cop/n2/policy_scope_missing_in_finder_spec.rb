# frozen_string_literal: true

require 'rubocop'
require 'rubocop/rspec/expect_offense'
require 'rubocop/rspec/support'
require_relative '../../../../lib/rubocop/cop/n2/policy_scope_missing_in_finder'

RSpec.describe RuboCop::Cop::N2::PolicyScopeMissingInFinder, :config do
  include RuboCop::RSpec::ExpectOffense

  it 'flags @x ||= Model.find without policy_scope' do
    expect_offense(<<~RUBY)
      @order ||= Order.find(params[:order_id])
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `policy_scope` when memoizing a finder — e.g. `@order ||= policy_scope(Order).find(params[:order_id])`.
    RUBY
    expect_correction(<<~RUBY)
      @order ||= policy_scope(Order).find(params[:order_id])
    RUBY
  end

  it 'flags @x ||= Model.find_by without policy_scope' do
    expect_offense(<<~RUBY)
      @user ||= User.find_by(email: params[:email])
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `policy_scope` when memoizing a finder — e.g. `@user ||= policy_scope(User).find_by(email: params[:email])`.
    RUBY
    expect_correction(<<~RUBY)
      @user ||= policy_scope(User).find_by(email: params[:email])
    RUBY
  end

  it 'flags namespaced constant without policy_scope' do
    expect_offense(<<~RUBY)
      @item ||= Admin::Item.find(params[:id])
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `policy_scope` when memoizing a finder — e.g. `@item ||= policy_scope(Admin::Item).find(params[:id])`.
    RUBY
    expect_correction(<<~RUBY)
      @item ||= policy_scope(Admin::Item).find(params[:id])
    RUBY
  end

  it 'flags @x ||= Model.includes(...).find without policy_scope' do
    expect_offense(<<~RUBY)
      @order ||= Order.includes(:client).find(params[:order_id])
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `policy_scope` when memoizing a finder — e.g. `@order ||= policy_scope(Order).includes(:client).find(params[:order_id])`.
    RUBY
    expect_correction(<<~RUBY)
      @order ||= policy_scope(Order).includes(:client).find(params[:order_id])
    RUBY
  end

  it 'does not flag @x ||= policy_scope(Model).find' do
    expect_no_offenses(<<~RUBY)
      @order ||= policy_scope(Order).find(params[:order_id])
    RUBY
  end

  it 'does not flag @x ||= policy_scope(Model).find_by' do
    expect_no_offenses(<<~RUBY)
      @user ||= policy_scope(User).find_by(email: params[:email])
    RUBY
  end

  it 'does not flag plain = assignment on constant (different cop)' do
    expect_no_offenses(<<~RUBY)
      @order = Order.find(params[:order_id])
    RUBY
  end

  it 'does not flag ||= without a find call' do
    expect_no_offenses(<<~RUBY)
      @order ||= Order.new
    RUBY
  end
end
