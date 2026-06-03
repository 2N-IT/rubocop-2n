# frozen_string_literal: true

module RuboCop
  module Cop
    module N2
      # Flags `{ key: key }` hash pairs where symbol key matches local variable name.
      # Suggests Ruby 3.1 shorthand `{ key: }`.
      class HashValueShorthand < Base
        extend AutoCorrector

        MSG = "Use Ruby 3.1 hash value shorthand `{ %<key>s: }` instead of `{ %<key>s: %<key>s }`."

        def on_pair(node)
          key, value = node.children
          return unless key.sym_type?
          return if shorthand_pair?(key, value)

          value_name =
            if value.lvar_type?
              value.children.first
            elsif value.send_type? && value.receiver.nil? && value.arguments.empty?
              value.method_name
            end

          return unless value_name
          return unless key.value == value_name

          key_name = key.value
          add_offense(node, message: format(MSG, key: key_name)) do |corrector|
            corrector.replace(node, "#{key_name}:")
          end
        end

        private

        def shorthand_pair?(key, value)
          key.loc.expression == value.loc.expression
        end
      end
    end
  end
end
