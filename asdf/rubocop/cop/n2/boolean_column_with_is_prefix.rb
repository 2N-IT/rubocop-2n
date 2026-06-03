# frozen_string_literal: true

module RuboCop
  module Cop
    module N2
      # Flags boolean column definitions with an `is_` prefix, in both
      # `add_column` and `create_table` block (`t.boolean`) forms.
      # The prefix is redundant — Rails automatically generates predicate
      # methods for every attribute, so naming the column `is_active` leads
      # to `record.is_active?` which is awkward. Prefer the bare adjective
      # (e.g. `active`).
      #
      # @example
      #   # bad
      #   add_column :users, :is_active, :boolean
      #
      #   # bad
      #   create_table :cats do |t|
      #     t.boolean :is_worm
      #   end
      #
      #   # good
      #   add_column :users, :active, :boolean
      #
      #   # good
      #   create_table :cats do |t|
      #     t.boolean :worm
      #   end
      class BooleanColumnWithIsPrefix < Base
        MSG = "Avoid `is_` prefix on boolean columns — use `%<suggested>s` instead of `%<original>s`."

        RESTRICT_ON_SEND = %i[add_column boolean].freeze

        def_node_matcher :add_column_with_is_prefix?, <<~PATTERN
          (send {nil? _} :add_column _ (sym #starts_with_is?) (sym :boolean) ...)
        PATTERN

        def_node_matcher :t_boolean_with_is_prefix?, <<~PATTERN
          (send _ :boolean (sym #starts_with_is?) ...)
        PATTERN

        def on_send(node)
          add_column_with_is_prefix?(node) do
            register_offense(node, node.arguments[1])
          end

          t_boolean_with_is_prefix?(node) do
            register_offense(node, node.arguments[0])
          end
        end

        private

        def register_offense(node, column_node)
          original = column_node.value.to_s
          suggested = original.delete_prefix("is_")
          add_offense(node, message: format(MSG, original: original, suggested: suggested))
        end

        def starts_with_is?(sym_name)
          sym_name.to_s.start_with?("is_")
        end
      end
    end
  end
end
