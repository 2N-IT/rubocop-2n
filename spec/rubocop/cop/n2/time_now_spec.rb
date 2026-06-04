# frozen_string_literal: true

RSpec.describe RuboCop::Cop::N2::TimeNow, :config do
  it 'flags Time.now' do
    expect_offense(<<~RUBY)
      Time.now
      ^^^^^^^^ Use `Time.current` instead of `Time.now` — it respects the configured time zone.
    RUBY

    expect_correction(<<~RUBY)
      Time.current
    RUBY
  end

  it 'flags Time.now within a larger chain' do
    expect_offense(<<~RUBY)
      Time.now.utc
      ^^^^^^^^ Use `Time.current` instead of `Time.now` — it respects the configured time zone.
    RUBY

    expect_correction(<<~RUBY)
      Time.current.utc
    RUBY
  end

  it 'flags ::Time.now' do
    expect_offense(<<~RUBY)
      ::Time.now
      ^^^^^^^^^^ Use `Time.current` instead of `Time.now` — it respects the configured time zone.
    RUBY

    expect_correction(<<~RUBY)
      ::Time.current
    RUBY
  end

  it 'does not flag Time.current' do
    expect_no_offenses(<<~RUBY)
      Time.current
    RUBY
  end

  it 'does not flag a receiverless now' do
    expect_no_offenses(<<~RUBY)
      now
    RUBY
  end

  it 'does not flag now on another constant' do
    expect_no_offenses(<<~RUBY)
      Clock.now
    RUBY
  end
end
