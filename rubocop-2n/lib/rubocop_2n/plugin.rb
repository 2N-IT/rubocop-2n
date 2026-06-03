# frozen_string_literal: true

require 'pathname'

module RuboCop
  module N2
    class Plugin < LintRoller::Plugin
      def about
        LintRoller::About.new(
          name: 'rubocop-2n',
          version: VERSION,
          homepage: '',
          description: '2N organisation RuboCop cops'
        )
      end

      def supported?(context)
        context.engine == :rubocop
      end

      def rules(_context)
        LintRoller::Rules.new(
          type: :path,
          config_format: :rubocop,
          value: Pathname.new(__dir__).join('../..', 'config', 'default.yml')
        )
      end
    end
  end
end
