# frozen_string_literal: true

require_relative 'lib/rubocop_2n/version'

Gem::Specification.new do |spec|
  spec.name    = 'rubocop-2n'
  spec.version = RuboCop::N2::VERSION
  spec.authors = ['2N']
  spec.summary = '2N organisation RuboCop cops'
  spec.license = 'MIT'

  spec.metadata['default_lint_roller_plugin'] = 'RuboCop::N2::Plugin'

  spec.files = Dir['lib/**/*.rb', 'config/**/*.yml']

  spec.required_ruby_version = '>= 3.0'

  spec.add_dependency 'rubocop', '>= 1.50'
  spec.add_dependency 'lint_roller', '>= 1.0'
  # Cross-file analysis graph used by N2::CopBase#graph. Tighten the version
  # constraint once rubydex is published / pinned to a known release.
  spec.add_dependency 'rubydex'
end
