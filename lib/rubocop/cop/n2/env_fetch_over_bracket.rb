# frozen_string_literal: true

module RuboCop
  module Cop
    module N2
      # Flags `ENV['KEY']` reads. Prefer `ENV.fetch('KEY')`, which fails fast
      # with a `KeyError` when the variable is missing instead of silently
      # returning `nil` and surfacing as a confusing error far from the cause.
      # Use `ENV.fetch('KEY', default)` when a fallback is appropriate.
      #
      # No autocorrection: `ENV['KEY']` returns `nil` for a missing key while
      # `ENV.fetch('KEY')` raises, so the rewrite changes behaviour and must be
      # done deliberately (with or without a default).
      #
      # @example
      #   # bad
      #   ENV['DATABASE_URL']
      #
      #   # good
      #   ENV.fetch('DATABASE_URL')
      #   ENV.fetch('DATABASE_URL', nil)
      class EnvFetchOverBracket < RuboCop::Cop::Base
        MSG = "Use `ENV.fetch('%<key>s')` instead of `ENV['%<key>s']` to fail fast on missing variables."

        RESTRICT_ON_SEND = %i[[]].freeze

        def_node_matcher :env_bracket?, <<~PATTERN
          (send (const {nil? cbase} :ENV) :[] (str $_))
        PATTERN

        def on_send(node)
          env_bracket?(node) do |key|
            add_offense(node, message: format(MSG, key: key))
          end
        end
      end
    end
  end
end
