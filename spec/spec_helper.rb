# frozen_string_literal: true

require 'rubocop'
require 'rubocop/rspec/expect_offense'
require 'rubocop/rspec/support'
require_relative '../lib/rubocop-2n'

RSpec.configure do |config|
  config.include RuboCop::RSpec::ExpectOffense
end
