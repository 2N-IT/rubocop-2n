# frozen_string_literal: true

require 'rubocop'
require 'rubocop/rspec/expect_offense'
require 'rubocop/rspec/support'
require_relative '../../../../lib/rubocop/cop/n2/redundant_local_from_method'

RSpec.describe RuboCop::Cop::N2::RedundantLocalFromMethod, :config do
  include RuboCop::RSpec::ExpectOffense

  context 'when variable is assigned from a zero-arg method call and used exactly once' do
    it 'flags the assignment' do
      expect_offense(<<~RUBY)
        def foo
          user = load_user
          ^^^^^^^^^^^^^^^^ Local variable `user` is assigned from a zero-argument method call and used only once — call `load_user` directly at the use site.
          authorize user
        end
      RUBY
    end

    it 'flags when used as a receiver' do
      expect_offense(<<~RUBY)
        def foo
          user = current_user
          ^^^^^^^^^^^^^^^^^^^ Local variable `user` is assigned from a zero-argument method call and used only once — call `current_user` directly at the use site.
          user.update!(active: true)
        end
      RUBY
    end

    it 'flags when used inside a block' do
      expect_offense(<<~RUBY)
        def foo
          items = load_items
          ^^^^^^^^^^^^^^^^^^ Local variable `items` is assigned from a zero-argument method call and used only once — call `load_items` directly at the use site.
          items.each { |x| puts x }
        end
      RUBY
    end

  end

  context 'when RHS is a chained call (has a receiver)' do
    it 'does not flag' do
      expect_no_offenses(<<~RUBY)
        def foo
          admin = current_user.admin
          authorize admin
        end
      RUBY
    end
  end

  context 'when RHS has arguments' do
    it 'does not flag' do
      expect_no_offenses(<<~RUBY)
        def foo
          result = fetch_user(params[:id])
          render json: result
        end
      RUBY
    end

    it 'does not flag with keyword arguments' do
      expect_no_offenses(<<~RUBY)
        def foo
          record = find_by(slug: params[:slug])
          render json: record
        end
      RUBY
    end
  end

  context 'when variable is used more than once' do
    it 'does not flag' do
      expect_no_offenses(<<~RUBY)
        def foo
          user = load_user
          log(user)
          authorize user
        end
      RUBY
    end
  end

  context 'when variable is reassigned before use' do
    it 'does not flag the original assignment' do
      expect_no_offenses(<<~RUBY)
        def foo
          result = load_record
          result = transform(result)
          render json: result
        end
      RUBY
    end

    it 'does not flag when reassigned conditionally (accumulator pattern)' do
      expect_no_offenses(<<~RUBY)
        def foo
          items = load_items
          items = items.filter_by(category) if category
          process(items)
        end
      RUBY
    end
  end

  context 'when variable is never used' do
    it 'does not flag (zero uses is a different issue)' do
      expect_no_offenses(<<~RUBY)
        def foo
          user = load_user
          render json: :ok
        end
      RUBY
    end
  end

  context 'when RHS is a literal' do
    it 'does not flag' do
      expect_no_offenses(<<~RUBY)
        def foo
          x = 42
          use(x)
        end
      RUBY
    end
  end

  context 'when RHS is a plain lvar' do
    it 'does not flag' do
      expect_no_offenses(<<~RUBY)
        def foo(original)
          copy = original
          use(copy)
        end
      RUBY
    end
  end
end
