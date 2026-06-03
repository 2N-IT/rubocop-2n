# frozen_string_literal: true

module RuboCop
  module N2
    module RubydexContext
      def self.graph
        @graph ||= begin
          require 'rubydex'
          Rubydex::Graph.build(Dir.pwd)
        end
      end
    end
  end
end
