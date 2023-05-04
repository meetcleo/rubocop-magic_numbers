# frozen_string_literal: true

module RuboCop
  module Cop
    module MagicNumbers
      # Base class for all shared behaviour between these cops
      class Base < ::RuboCop::Cop::Cop
        ILLEGAL_SCALAR_TYPES = %i[float int].freeze
        ILLEGAL_SCALAR_PATTERN = "{#{ILLEGAL_SCALAR_TYPES.join(' ')}}".freeze

        private

        def node_matches_pattern?(node:, pattern:)
          RuboCop::AST::NodePattern.new(pattern).match(node)
        end
      end
    end
  end
end
