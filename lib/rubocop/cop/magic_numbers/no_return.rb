# frozen_string_literal: true

require_relative 'base'

module RuboCop
  module Cop
    module MagicNumbers
      # Raises an offense if a method returns with a magic number
      # Catches both explicit and implicit returns
      class NoReturn < Base
        MAGIC_NUMBER_RETURN_PATTERN = <<~PATTERN.chomp
          (%<illegal_scalar_pattern>s _)
        PATTERN
        NO_EXPLICIT_RETURN_MSG = 'Do not return magic numbers from a method or proc'

        def on_def(node)
          return unless implicit_return?(node.children.last)

          add_offense(node.children.last, location: :expression, message: NO_EXPLICIT_RETURN_MSG)
        end

        def on_return(node)
          return unless forbidden_numerics.include?(node.children.first&.type)

          add_offense(node.children.first, location: :expression, message: NO_EXPLICIT_RETURN_MSG)
        end

        private

        def implicit_return?(node)
          return implicit_return?(node.children.last) if node.begin_type?

          pattern = format(MAGIC_NUMBER_RETURN_PATTERN, {
                             illegal_scalar_pattern:
                           })
          node_matches_pattern?(node:, pattern:)
        end
      end
    end
  end
end
