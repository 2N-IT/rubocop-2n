# frozen_string_literal: true

module RuboCop
  module Cop
    module N2
      # Flags `before_action :set_X` patterns. Prefer a memoized private method
      # named after the resource, called directly in each action.
      #
      # @example
      #   # bad
      #   before_action :set_user
      #
      #   def set_user
      #     @user = policy_scope(User).find(params[:id])
      #   end
      #
      #   # good
      #   def show
      #     user
      #   end
      #
      #   private
      #
      #   def user
      #     @user ||= policy_scope(User).find(params[:id])
      #   end
      class BeforeActionSetX < CopBase
        MSG = "Avoid `before_action :%<callback>s` — prefer a memoized `def %<resource>s` called directly in each action."

        RESTRICT_ON_SEND = %i[before_action].freeze

        def_node_matcher :before_action_set?, <<~PATTERN
          (send nil? :before_action (sym /^set_/) ...)
        PATTERN

        def on_send(node)
          before_action_set?(node) do
            callback = node.arguments.first.value
            resource = callback.to_s.delete_prefix("set_")
            add_offense(node, message: format(MSG, callback: callback, resource: resource))
          end
        end
      end
    end
  end
end
