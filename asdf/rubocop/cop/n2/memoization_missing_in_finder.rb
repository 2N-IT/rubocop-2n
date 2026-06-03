# frozen_string_literal: true

module RuboCop
  module Cop
    module N2
      # Flags plain ivar assignments (`@x = ...find(...)`) inside a method
      # whose name matches the ivar. Such methods are memoized accessors by
      # convention and must use `||=` to avoid hitting the database on every
      # call.
      #
      # @example
      #   # bad
      #   def order
      #     @order = Order.find(params[:order_id])
      #   end
      #
      #   # bad
      #   def order
      #     @order = policy_scope(Order).find(params[:order_id])
      #   end
      #
      #   # good
      #   def order
      #     @order ||= policy_scope(Order).find(params[:order_id])
      #   end
      class MemoizationMissingInFinder < Base
        extend AutoCorrector

        MSG = "Memoize the finder with `||=` instead of `=` — " \
              "e.g. `%<suggestion>s`."

        # Matches: @x = <anything>.find(...) or .find_by(...)
        def_node_matcher :unmemoized_finder?, <<~PATTERN
          (ivasgn $_
            (send _ {:find :find_by} ...))
        PATTERN

        def on_ivasgn(node)
          unmemoized_finder?(node) do |ivar_name|
            return unless inside_matching_method?(node, ivar_name)

            finder_node = node.children[1]
            suggestion = "#{ivar_name} ||= #{finder_node.source}"
            add_offense(node, message: format(MSG, suggestion: suggestion)) do |corrector|
              corrector.replace(node.loc.operator, "||=")
            end
          end
        end

        private

        def inside_matching_method?(node, ivar_name)
          node.each_ancestor(:def).any? do |def_node|
            def_node.method_name.to_s == ivar_name.to_s.delete_prefix("@")
          end
        end
      end
    end
  end
end
