# frozen_string_literal: true

module RuboCop
  module Cop
    module N2
      # Flags local variables assigned from a zero-argument method call and used
      # exactly once. Since the method name already describes what the value is,
      # the intermediate variable adds no information — call the method directly
      # at the use site.
      #
      # Only fires when:
      # - the RHS is a zero-argument method call (arguments → no offense)
      # - the variable appears exactly once after the assignment in the same scope
      # - the variable is not a pipeline step (RHS does not read the same var)
      #
      # No autocorrect: must be a conscious decision.
      #
      # @example
      #   # bad
      #   user = load_user
      #   authorize user
      #
      #   # good — inline
      #   authorize load_user
      #
      #   # good — has arguments, intermediate may clarify intent
      #   result = fetch_user(params[:id])
      #   render json: result
      class RedundantLocalFromMethod < RuboCop::Cop::Base
        MSG = "Local variable `%<name>s` is assigned from a zero-argument method call and used only once — call `%<method>s` directly at the use site."

        def on_begin(node)
          stmts = node.children
          stmts.each_with_index do |stmt, idx|
            next unless assignment_from_call?(stmt)

            var_name = stmt.children[0]

            # Skip pipeline steps: `x = transform(x)` — the RHS reads the same var.
            next if contains_lvar_read?(stmt.children[1], var_name)

            remaining = stmts[(idx + 1)..]

            # If the variable is ever reassigned downstream, it's being used as a
            # mutable accumulator — not redundant regardless of read count.
            next if reassigned_in?(remaining, var_name)

            next unless used_exactly_once?(var_name, remaining)

            method_name = stmt.children[1].method_name
            add_offense(stmt, message: format(MSG, name: var_name, method: method_name))
          end
        end

        private

        def assignment_from_call?(node)
          return false unless node.lvasgn_type?

          rhs = node.children[1]
          return false unless rhs&.send_type? || rhs&.csend_type?

          rhs.arguments.empty? && rhs.receiver.nil?
        end

        def reassigned_in?(stmts, var_name)
          stmts.any? { |stmt| contains_lvasgn?(stmt, var_name) }
        end

        def contains_lvasgn?(node, var_name)
          return false if node.nil?
          return true if node.lvasgn_type? && node.children[0] == var_name

          node.each_child_node.any? { |child| contains_lvasgn?(child, var_name) }
        end

        def used_exactly_once?(var_name, stmts)
          count = stmts.sum { |stmt| count_lvar_reads(stmt, var_name) }
          count == 1
        end

        def contains_lvar_read?(node, var_name)
          return false if node.nil?
          return true if lvar_read?(node, var_name)

          node.each_child_node.any? { |child| contains_lvar_read?(child, var_name) }
        end

        def count_lvar_reads(node, var_name)
          return 0 if node.nil?
          # Don't count the lvar on the LHS of a reassignment to the same name
          return 0 if reassigns?(node, var_name)

          own = lvar_read?(node, var_name) ? 1 : 0
          own + node.each_child_node.sum { |child| count_lvar_reads(child, var_name) }
        end

        def lvar_read?(node, var_name)
          node.lvar_type? && node.children[0] == var_name
        end

        def reassigns?(node, var_name)
          node.lvasgn_type? && node.children[0] == var_name
        end
      end
    end
  end
end
