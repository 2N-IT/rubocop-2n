# frozen_string_literal: true

RSpec.describe RuboCop::Cop::N2::PluckOverMapAttribute, :config do
  context 'with the symbol-proc form' do
    it 'flags map(&:email) after where' do
      expect_offense(<<~RUBY)
        User.where(active: true).map(&:email)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `pluck(:email)` instead of `map` to avoid loading full records.
      RUBY

      expect_correction(<<~RUBY)
        User.where(active: true).pluck(:email)
      RUBY
    end

    it 'flags map after all' do
      expect_offense(<<~RUBY)
        Account.all.map(&:id)
        ^^^^^^^^^^^^^^^^^^^^^ Use `pluck(:id)` instead of `map` to avoid loading full records.
      RUBY

      expect_correction(<<~RUBY)
        Account.all.pluck(:id)
      RUBY
    end
  end

  context 'with the block form' do
    it 'flags a single attribute read' do
      expect_offense(<<~RUBY)
        User.where(active: true).map { |u| u.id }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `pluck(:id)` instead of `map` to avoid loading full records.
      RUBY

      expect_correction(<<~RUBY)
        User.where(active: true).pluck(:id)
      RUBY
    end

    it 'flags an array of attribute reads' do
      expect_offense(<<~RUBY)
        Client.order(:company_name).map { |c| [c.company_name, c.id] }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `pluck(:company_name, :id)` instead of `map` to avoid loading full records.
      RUBY

      expect_correction(<<~RUBY)
        Client.order(:company_name).pluck(:company_name, :id)
      RUBY
    end

    it 'does not flag a block that does real work' do
      expect_no_offenses(<<~RUBY)
        Client.all.map { |c| "\#{c.company_name} (\#{c.id})" }
      RUBY
    end

    it 'does not flag a block with a method call on the element' do
      expect_no_offenses(<<~RUBY)
        Client.all.map { |c| [c.name, foo(c)] }
      RUBY
    end

    it 'does not flag nested attribute access' do
      expect_no_offenses(<<~RUBY)
        Client.all.map { |c| c.account.id }
      RUBY
    end
  end

  context 'when the chain already returns an Array' do
    it 'does not flag map after pluck' do
      expect_no_offenses(<<~RUBY)
        Clients.order.pluck(:id, :name).map { |c| c.first }
      RUBY
    end

    it 'does not flag map after select' do
      expect_no_offenses(<<~RUBY)
        Clients.where(active: true).select(:id).map(&:id)
      RUBY
    end
  end

  context 'when the receiver type is unknown' do
    it 'does not flag a bare local variable receiver' do
      expect_no_offenses(<<~RUBY)
        users.map(&:id)
      RUBY
    end

    it 'does not flag a method-call receiver without AR query methods' do
      expect_no_offenses(<<~RUBY)
        user.posts.map(&:id)
      RUBY
    end

    it 'does not flag an array literal' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3].map(&:to_s)
      RUBY
    end
  end

  context 'when it is not a projecting map' do
    it 'does not flag map(&method(:wrap))' do
      expect_no_offenses(<<~RUBY)
        User.all.map(&method(:wrap))
      RUBY
    end

    it 'does not flag pluck' do
      expect_no_offenses(<<~RUBY)
        User.all.pluck(:id)
      RUBY
    end
  end
end
