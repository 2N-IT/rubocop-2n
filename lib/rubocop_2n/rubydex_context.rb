# frozen_string_literal: true

module RuboCop
  module N2
    module RubydexContext
      def self.graph
        @graph ||= begin
          require 'rubydex'
          graph = Rubydex::Graph.new(workspace_path: Dir.pwd)
          graph.index_workspace
          graph.resolve
          graph
        end
      end
    end
  end
end
