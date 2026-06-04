# frozen_string_literal: true

module RuboCop
  module Cop
    module N2
      # Flags `Time.now` (and `Time.now.utc`). Prefer `Time.current`, which is
      # timezone-aware and respects `Time.zone` configured by Rails. `Time.now`
      # returns system local time, which leads to off-by-hours bugs in apps that
      # run in a non-UTC zone or serve users across zones.
      #
      # @example
      #   # bad
      #   Time.now
      #   Time.now.utc
      #
      #   # good
      #   Time.current
      class TimeNow < RuboCop::Cop::Base
        extend AutoCorrector

        MSG = "Use `Time.current` instead of `Time.now` — it respects the configured time zone."

        RESTRICT_ON_SEND = %i[now].freeze

        def_node_matcher :time_now?, <<~PATTERN
          (send (const {nil? cbase} :Time) :now)
        PATTERN

        def on_send(node)
          time_now?(node) do
            add_offense(node) do |corrector|
              corrector.replace(node, "#{node.receiver.source}.current")
            end
          end
        end
      end
    end
  end
end
