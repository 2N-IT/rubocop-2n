# frozen_string_literal: true

module RuboCop
  module Cop
    module N2
      # Flags ivar memoization assignments (`@x ||= ...`) that call `.find` or
      # `.find_by` without going through `policy_scope` anywhere in the receiver
      # chain. Using the raw model bypasses Pundit scoping and can expose records
      # the current user should not see.
      #
      # @example
      #   # bad
      #   def order
      #     @order ||= Order.find(params[:order_id])
      #   end
      #
      #   # bad
      #   def order
      #     @order ||= Order.includes(:client).find(params[:order_id])
      #   end
      #
      #   # good
      #   def order
      #     @order ||= policy_scope(Order).find(params[:order_id])
      #   end
      class PolicyScopeMissingInFinder < Base
        extend AutoCorrector

        MSG = "Use `policy_scope` when memoizing a finder — " \
              "e.g. `%<suggestion>s`."

        RESTRICT_ON_SEND = %i[find find_by].freeze

        # Matches: @x ||= <anything>.find(...) or .find_by(...)
        def_node_matcher :memoized_finder?, <<~PATTERN
          (or-asgn
            (ivasgn $_)
            (send _ {:find :find_by} ...))
        PATTERN

        def on_or_asgn(node)
          memoized_finder?(node) do |ivar_name|
            finder_node = node.children[1]
            return if policy_scoped?(finder_node.receiver)

            root = receiver_root(finder_node.receiver)
            suggestion = "#{ivar_name} ||= policy_scope(#{root.source}).#{finder_node.source.split('.', 2).last}"
            add_offense(node, message: format(MSG, suggestion: suggestion)) do |corrector|
              corrector.replace(root, "policy_scope(#{root.source})")
            end
          end
        end

        private

        def policy_scoped?(node)
          return false if node.nil?
          return true if node.send_type? && node.method_name == :policy_scope

          policy_scoped?(node.receiver) if node.respond_to?(:receiver)
        end

        def receiver_root(node)
          return node unless node.respond_to?(:receiver) && node.receiver

          receiver_root(node.receiver)
        end
      end
    end
  end
end
