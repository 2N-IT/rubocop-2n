# frozen_string_literal: true

module RuboCop
  module Cop
    module N2
      # Flags ActiveRecord enum declarations that use integer values.
      # String-backed enums are safer: they are readable in raw DB queries,
      # immune to insertion-order bugs, and survive reordering without data loss.
      #
      # Supports both the modern positional form and the legacy keyword form.
      #
      # @example
      #   # bad
      #   enum :status, { active: 0, inactive: 1 }
      #
      #   # bad — array form maps to integers by position (both %i[] and %w[])
      #   enum :status, %i[active inactive]
      #
      #   # bad
      #   enum :status, %w[active inactive]
      #
      #   # bad (legacy keyword form)
      #   enum status: { active: 0, inactive: 1 }
      #
      #   # good
      #   enum :status, { active: "active", inactive: "inactive" }
      #
      #   # good (legacy keyword form)
      #   enum status: { active: "active", inactive: "inactive" }
      class IntegerEnumInModel < CopBase
        MSG = "Prefer string-backed enums `key: \"key\"` over integer-backed - " \
              "safer in raw DB queries and immune to insertion-order bugs."

        RESTRICT_ON_SEND = %i[enum].freeze

        # Modern form with explicit integers: enum :status, { active: 0 }
        def_node_matcher :modern_integer_enum?, <<~PATTERN
          (send {nil? _} :enum (sym _) (hash (pair _ (int _)) ...) ...)
        PATTERN

        # Modern form with array (position-based integers): enum :status, %i[active inactive]
        # Also catches %w[] string arrays — Rails still uses position as the DB integer.
        def_node_matcher :modern_array_enum?, <<~PATTERN
          (send {nil? _} :enum (sym _) (array _ ...) ...)
        PATTERN

        # Legacy keyword form with explicit integers: enum status: { active: 0 }
        def_node_matcher :legacy_integer_enum?, <<~PATTERN
          (send {nil? _} :enum (hash (pair (sym _) (hash (pair _ (int _)) ...)) ...))
        PATTERN

        # Legacy keyword form with array: enum status: %i[active inactive] or %w[active inactive]
        def_node_matcher :legacy_array_enum?, <<~PATTERN
          (send {nil? _} :enum (hash (pair (sym _) (array _ ...)) ...))
        PATTERN

        def on_send(node)
          return unless modern_integer_enum?(node) ||
                        modern_array_enum?(node) ||
                        legacy_integer_enum?(node) ||
                        legacy_array_enum?(node)

          add_offense(node)
        end
      end
    end
  end
end
