# frozen_string_literal: true

module RuboCop
  module Cop
    module N2
      # Base class for all N2 cops.
      #
      # Exposes the Rubydex cross-file graph so cops that reason about
      # relationships between files (finders, policies, models) don't each
      # have to require and call into RubydexContext directly.
      class CopBase < RuboCop::Cop::Base
        private

        def graph
          RuboCop::N2::RubydexContext.graph
        end
      end
    end
  end
end
