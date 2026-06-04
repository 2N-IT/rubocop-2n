# frozen_string_literal: true

module RuboCop
  module Cop
    module N2
      # Flags `relation.map { ... }` / `relation.map(&:attr)` on what looks like
      # an ActiveRecord relation, where `pluck` would select only the needed
      # columns at the database level instead of instantiating a full model per
      # row.
      #
      # Detecting an AR relation statically is impossible in general, so this cop
      # only fires when the receiver chain *looks* like AR:
      #
      #   * its root is a constant that resolves (via the Rubydex graph) to an
      #     `ApplicationRecord` / `ActiveRecord::Base` descendant, or
      #   * the chain contains a known AR query method (`where`, `all`, ...).
      #
      # The chain must NOT already contain `pluck` or `select` — those return a
      # plain Array, so the trailing `map` is array work, not a relation load.
      #
      # The mapping must be a pure attribute projection: `&:attr`, `{ |c| c.attr }`,
      # or `{ |c| [c.a, c.b] }`. Any other work in the block (string building,
      # method calls, nested access) means it is not a plain `pluck`, so it is
      # left alone.
      #
      # @example
      #   # bad
      #   User.active.map(&:id)
      #   Client.order(:name).map { |c| [c.name, c.id] }
      #
      #   # good
      #   User.active.pluck(:id)
      #   Client.order(:name).pluck(:name, :id)
      #
      #   # not flagged
      #   users.map(&:id)                              # receiver type unknown
      #   Client.pluck(:id, :name).map { |c| c.first } # already an Array
      #   Client.all.map { |c| "#{c.name} (#{c.id})" } # block does real work
      class PluckOverMapAttribute < CopBase
        extend AutoCorrector

        MSG = "Use `pluck(%<attrs>s)` instead of `map` to avoid loading full records."

        # Methods that strongly imply an ActiveRecord relation receiver.
        AR_QUERY_METHODS = %i[
          all none unscoped
          where where_not rewhere
          includes preload eager_load references
          joins left_joins left_outer_joins
          order reorder reverse_order
          limit offset group having distinct
          find_each find_in_batches in_batches
          extending only except
        ].to_set.freeze

        # Methods whose presence means the chain already returns an Array.
        ARRAY_RETURNING_METHODS = %i[pluck select].to_set.freeze

        AR_ANCESTORS = %w[ApplicationRecord ActiveRecord::Base].freeze

        # `map(&:attr)` — the symbol-proc form.
        def_node_matcher :map_symbol_proc?, <<~PATTERN
          ({send csend} $_ :map (block-pass (sym $_)))
        PATTERN

        # `map { |x| ... }` — capture receiver, the single block arg, and body.
        def_node_matcher :map_block?, <<~PATTERN
          (block ({send csend} $_ :map) (args (arg $_)) $_)
        PATTERN

        def on_send(node)
          map_symbol_proc?(node) do |receiver, attr|
            register(node, receiver, [attr])
          end
        end
        alias_method :on_csend, :on_send

        def on_block(node)
          map_block?(node) do |receiver, arg, body|
            attrs = projected_attrs(body, arg)
            next unless attrs

            register(node, receiver, attrs)
          end
        end

        private

        def register(node, receiver, attrs)
          return unless active_record_relation?(receiver)

          attr_list = attrs.map { |a| ":#{a}" }.join(", ")
          add_offense(node, message: format(MSG, attrs: attr_list)) do |corrector|
            autocorrect(corrector, node, attr_list)
          end
        end

        def autocorrect(corrector, node, attr_list)
          if node.block_type?
            # Replace from `map` through the closing brace in one range so the
            # space before the block (`map { ... }`) does not survive.
            range = node.send_node.loc.selector.join(node.loc.end)
            corrector.replace(range, "pluck(#{attr_list})")
          else
            corrector.replace(node.loc.selector, "pluck")
            corrector.replace(node.first_argument, attr_list)
          end
        end

        # Returns the list of attribute symbols if `body` is a pure projection
        # of the block argument (`x.attr` or `[x.a, x.b]`), otherwise nil.
        def projected_attrs(body, arg)
          case body.type
          when :send
            attr = bare_attr_read(body, arg)
            [attr] if attr
          when :array
            attrs = body.children.map { |el| bare_attr_read(el, arg) }
            attrs if attrs.all? && !attrs.empty?
          end
        end

        # `x.attr` where the receiver is exactly the block arg lvar and there are
        # no arguments — returns :attr, otherwise nil.
        def bare_attr_read(node, arg)
          return unless node.send_type?
          return unless node.arguments.empty?

          receiver = node.receiver
          return unless receiver&.lvar_type? && receiver.children.first == arg

          node.method_name
        end

        def active_record_relation?(receiver)
          return false unless receiver
          return false if chain_returns_array?(receiver)

          chain_uses_ar_query_method?(receiver) || ar_model_constant_root?(receiver)
        end

        # True if the chain already contains a method that materialises an Array
        # (`pluck`, `select`), making a trailing `map` array work, not a query.
        def chain_returns_array?(node)
          while node&.send_type? || node&.csend_type?
            return true if ARRAY_RETURNING_METHODS.include?(node.method_name)

            node = node.receiver
          end
          false
        end

        # Walks down the call chain looking for a method only an ActiveRecord
        # relation would respond to.
        def chain_uses_ar_query_method?(node)
          while node&.send_type? || node&.csend_type?
            return true if AR_QUERY_METHODS.include?(node.method_name)

            node = node.receiver
          end
          false
        end

        # Resolves the constant at the root of the chain and checks whether it
        # descends from ActiveRecord. Best-effort: silently returns false when
        # the graph is unavailable or the constant cannot be resolved.
        def ar_model_constant_root?(node)
          node = node.receiver while node.respond_to?(:receiver) && node.receiver
          return false unless node&.const_type?

          declaration = resolve_constant(node)
          return false unless declaration.respond_to?(:has_ancestor?)

          declaration.has_ancestor?(*AR_ANCESTORS)
        end

        def resolve_constant(const_node)
          graph[const_node.const_name]
        rescue StandardError
          nil
        end
      end
    end
  end
end
