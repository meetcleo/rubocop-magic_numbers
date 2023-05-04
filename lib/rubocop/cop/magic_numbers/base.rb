module RuboCop
  module Cop
    module MagicNumbers
      class Base < ::RuboCop::Cop::Cop
        ILLEGAL_SCALAR_TYPES = %i[float int].freeze
        ILLEGAL_SCALAR_PATTERN = "{#{ILLEGAL_SCALAR_TYPES.join(" ")}".freeze

        private

        def node_matches_pattern?(node:, pattern:)
          RuboCop::AST::NodePattern.new(pattern).match(node)
        end
      end
    end
  end
end