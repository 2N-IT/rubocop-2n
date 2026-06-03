# frozen_string_literal: true

require 'rubocop'
require 'rubocop/rspec/expect_offense'
require 'rubocop/rspec/support'
require_relative '../../../../lib/rubocop/cop/n2/memoization_missing_in_finder'

RSpec.describe RuboCop::Cop::N2::MemoizationMissingInFinder, :config do
  include RuboCop::RSpec::ExpectOffense

  it 'flags @x = Model.find without ||= inside matching method' do
    expect_offense(<<~RUBY)
      def product
        @product = Product.find(params[:id])
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Memoize the finder with `||=` instead of `=` — e.g. `@product ||= Product.find(params[:id])`.
      end
    RUBY
    expect_correction(<<~RUBY)
      def product
        @product ||= Product.find(params[:id])
      end
    RUBY
  end

  it 'flags @x = policy_scope(Model).find without ||= inside matching method' do
    expect_offense(<<~RUBY)
      def order
        @order = policy_scope(Order).find(params[:order_id])
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Memoize the finder with `||=` instead of `=` — e.g. `@order ||= policy_scope(Order).find(params[:order_id])`.
      end
    RUBY
    expect_correction(<<~RUBY)
      def order
        @order ||= policy_scope(Order).find(params[:order_id])
      end
    RUBY
  end

  it 'flags @x = Model.find_by without ||= inside matching method' do
    expect_offense(<<~RUBY)
      def user
        @user = User.find_by(email: params[:email])
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Memoize the finder with `||=` instead of `=` — e.g. `@user ||= User.find_by(email: params[:email])`.
      end
    RUBY
    expect_correction(<<~RUBY)
      def user
        @user ||= User.find_by(email: params[:email])
      end
    RUBY
  end

  it 'flags @x = Model.includes(...).find without ||= inside matching method' do
    expect_offense(<<~RUBY)
      def product
        @product = Product.includes(:category).find(params[:id])
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Memoize the finder with `||=` instead of `=` — e.g. `@product ||= Product.includes(:category).find(params[:id])`.
      end
    RUBY
    expect_correction(<<~RUBY)
      def product
        @product ||= Product.includes(:category).find(params[:id])
      end
    RUBY
  end

  it 'does not flag @x ||= policy_scope(Model).find' do
    expect_no_offenses(<<~RUBY)
      def order
        @order ||= policy_scope(Order).find(params[:order_id])
      end
    RUBY
  end

  it 'does not flag @x ||= Model.find' do
    expect_no_offenses(<<~RUBY)
      def product
        @product ||= Product.find(params[:id])
      end
    RUBY
  end

  it 'does not flag when method name does not match ivar' do
    expect_no_offenses(<<~RUBY)
      def set_product
        @product = Product.find(params[:id])
      end
    RUBY
  end

  it 'does not flag local variable assignment with find' do
    expect_no_offenses(<<~RUBY)
      def show
        product = Product.find(params[:id])
      end
    RUBY
  end
end
