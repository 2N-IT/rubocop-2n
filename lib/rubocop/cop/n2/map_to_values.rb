# frozen_string_literal: true

module RuboCop
  module Cop
    module N2
      # Flags `.map { |_k, v| v }` or `.map { |_, v| v }` patterns.
      # Use `.values` for simple hash-to-values transformations.
      #
      # @example
      #   # bad
      #   hash.map { |_k, v| v }
      #   hash.map { |_, v| v }
      #
      #   # good
      #   hash.values
      class MapToValues < CopBase
        extend AutoCorrector

        MSG = "Use `%<suggestion>s` instead of `.map { |_, v| v }`."

        def_node_matcher :map_to_values_block?, <<~PATTERN
          (block
            (send _ :map)
            (args
              (arg $_ignored)
              (arg $_value))
            (lvar $_body))
        PATTERN

        def on_block(node) # rubocop:disable InternalAffairs/NumblockHandler
          map_to_values_block?(node) do |ignored, value, body|
            next unless ignored_arg?(ignored) && value == body

            receiver = node.send_node.receiver
            suggestion = "#{receiver.source}.values"
            add_offense(node, message: format(MSG, suggestion: suggestion)) do |corrector|
              corrector.replace(node, suggestion)
            end
          end
        end

        private

        def ignored_arg?(name)
          name == :_ || name.to_s.start_with?("_")
        end
      end
    end
  end
end
