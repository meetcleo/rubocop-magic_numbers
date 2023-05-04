# frozen_string_literal: true

require_relative 'no_magic_numbers'

module RuboCop
  module Cop
    module MagicNumbers
      # Raises an offense if a method returns with a magic number
      # Catches both explicit and implicit returns
      class NoReturn < NoMagicNumbers
        MAGIC_NUMBER_RETURN_PATTERN = <<~PATTERN.chomp.freeze
          ({#{ILLEGAL_SCALAR_TYPES.join(' ')}} _)
        PATTERN
        NO_EXPLICIT_RETURN_MSG = 'Do not return magic numbers from a method or proc'

        def on_def(node)
          return unless implicit_return?(node.children.last)

          add_offense(node, location: :expression, message: NO_EXPLICIT_RETURN_MSG)
        end

        def on_return(node)
          return unless ILLEGAL_SCALAR_TYPES.include?(node.children.first.type)

          add_offense(node, location: :expression, message: NO_EXPLICIT_RETURN_MSG)
        end

        private

        def implicit_return?(node)
          node_matches_pattern?(node:, pattern: MAGIC_NUMBER_RETURN_PATTERN)
        end
      end
    end
  end
end