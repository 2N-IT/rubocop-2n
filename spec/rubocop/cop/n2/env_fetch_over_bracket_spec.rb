# frozen_string_literal: true

RSpec.describe RuboCop::Cop::N2::EnvFetchOverBracket, :config do
  it 'flags ENV with a string key' do
    expect_offense(<<~RUBY)
      ENV['DATABASE_URL']
      ^^^^^^^^^^^^^^^^^^^ Use `ENV.fetch('DATABASE_URL')` instead of `ENV['DATABASE_URL']` to fail fast on missing variables.
    RUBY
  end

  it 'flags ::ENV with a string key' do
    expect_offense(<<~RUBY)
      ::ENV['SECRET']
      ^^^^^^^^^^^^^^^ Use `ENV.fetch('SECRET')` instead of `ENV['SECRET']` to fail fast on missing variables.
    RUBY
  end

  it 'does not autocorrect (semantic change)' do
    expect_offense(<<~RUBY)
      ENV['DATABASE_URL']
      ^^^^^^^^^^^^^^^^^^^ Use `ENV.fetch('DATABASE_URL')` instead of `ENV['DATABASE_URL']` to fail fast on missing variables.
    RUBY

    expect_no_corrections
  end

  it 'does not flag ENV.fetch' do
    expect_no_offenses(<<~RUBY)
      ENV.fetch('DATABASE_URL')
    RUBY
  end

  it 'does not flag ENV.fetch with a default' do
    expect_no_offenses(<<~RUBY)
      ENV.fetch('DATABASE_URL', nil)
    RUBY
  end

  it 'does not flag bracket access on another constant' do
    expect_no_offenses(<<~RUBY)
      CONFIG['DATABASE_URL']
    RUBY
  end

  it 'does not flag ENV bracket with a non-string key' do
    expect_no_offenses(<<~RUBY)
      ENV[key]
    RUBY
  end

  it 'does not flag ENV[key] ||= value (conditional assignment)' do
    expect_no_offenses(<<~RUBY)
      ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)
    RUBY
  end

  it 'does not flag ::ENV[key] ||= value' do
    expect_no_offenses(<<~RUBY)
      ::ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)
    RUBY
  end

  it 'does not flag ENV[key].present?' do
    expect_no_offenses(<<~RUBY)
      ENV['CI'].present?
    RUBY
  end

  it 'does not flag ENV[key].blank?' do
    expect_no_offenses(<<~RUBY)
      ENV['CI'].blank?
    RUBY
  end

  it 'does not flag ENV[key].nil?' do
    expect_no_offenses(<<~RUBY)
      ENV['CI'].nil?
    RUBY
  end

  it 'does not flag ENV[key].empty?' do
    expect_no_offenses(<<~RUBY)
      ENV['CI'].empty?
    RUBY
  end
end
