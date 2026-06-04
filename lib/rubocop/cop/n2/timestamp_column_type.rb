# frozen_string_literal: true

module RuboCop
  module Cop
    module N2
      # Flags `created_at` / `updated_at` columns declared individually as
      # `datetime` (or `timestamp`) instead of via the `t.timestamps` helper.
      # `t.timestamps` declares both columns with the correct type and
      # `null: false` defaults in one line, keeping migrations consistent.
      #
      # Covers both the `create_table` block form (`t.datetime :created_at`)
      # and the standalone `add_column :table, :created_at, :datetime` form.
      #
      # No autocorrection: the fix collapses the matching pair of columns into a
      # single `t.timestamps`, which can't be derived from one offending line.
      #
      # @example
      #   # bad
      #   create_table :users do |t|
      #     t.datetime :created_at
      #     t.datetime :updated_at
      #   end
      #
      #   # bad
      #   add_column :users, :updated_at, :datetime
      #
      #   # good
      #   create_table :users do |t|
      #     t.timestamps
      #   end
      class TimestampColumnType < RuboCop::Cop::Base
        MSG = "Use `t.timestamps` instead of declaring `%<column>s` as a `%<type>s` column."

        TIMESTAMP_COLUMNS = %i[created_at updated_at].freeze
        TIMESTAMP_TYPES = %i[datetime timestamp].freeze

        RESTRICT_ON_SEND = %i[datetime timestamp add_column].freeze

        def_node_matcher :t_timestamp_column?, <<~PATTERN
          (send _ ${:datetime :timestamp} (sym $#timestamp_column?) ...)
        PATTERN

        def_node_matcher :add_timestamp_column?, <<~PATTERN
          (send {nil? _} :add_column _ (sym $#timestamp_column?) (sym ${:datetime :timestamp}) ...)
        PATTERN

        def on_send(node)
          t_timestamp_column?(node) do |type, column|
            add_offense(node, message: format(MSG, column: column, type: type))
          end

          add_timestamp_column?(node) do |column, type|
            add_offense(node, message: format(MSG, column: column, type: type))
          end
        end

        private

        def timestamp_column?(name)
          TIMESTAMP_COLUMNS.include?(name)
        end
      end
    end
  end
end
