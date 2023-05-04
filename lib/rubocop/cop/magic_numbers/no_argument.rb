# frozen_string_literal: true

require_relative 'no_magic_numbers'

module RuboCop
  module Cop
    module MagicNumbers
      # Adds violations for magic numbers, when used as default values for
      # arguments to methods
      #
      # bad: def on_the_wall(bottles = 100)
      #
      # good: def on_the_wall(bottles = DEFAULT_BOTTLE_COUNT)
      class NoArgument < NoMagicNumbers
        ILLEGAL_SCALAR_TYPES = {
          'All' => %i[float int],
          'Integer' => %i[int],
          'Float' => %i[float]
        }.freeze

        MAGIC_NUMBER_OPTIONAL_ARGUMENT_PATTERN = lambda { |illegal_scalar_types_ast:|
          <<-PATTERN
            (def
              _
              (args
                <({kwoptarg optarg}
                  _
                  (#{illegal_scalar_types_ast} _)
                ) ...>
              )
              ...
            )
          PATTERN
        }

        MAGIC_NUMBER_ARGUMENT_PATTERN = lambda { |illegal_scalar_types_ast:|
          <<-PATTERN.freeze
            (send
              {
                _
                _
                (#{illegal_scalar_types_ast} _)
                | # This is a union of lhs and rhs literal
                (#{illegal_scalar_types_ast} _)
                _
                _
              }
            )
          PATTERN
        }

        DEFAULT_OPTIONAL_ARGUMENT_MSG = 'Do not use magic number optional ' \
                                        'argument defaults'

        ARGUMENT_MSG = 'Do not use magic number arguments to methods'

        def on_method_defined(node)
          return unless illegal_positional_default?(node)

          add_offense(
            node,
            location: :expression,
            message: DEFAULT_OPTIONAL_ARGUMENT_MSG
          )
        end
        alias on_def on_method_defined # rubocop API method name

        def on_message_send(node)
          return unless illegal_argument?(node)

          add_offense(node, location: :expression, message: ARGUMENT_MSG)
        end
        alias on_send on_message_send # rubocop API method name

        private

        def node_matches_pattern?(node:, pattern:)
          RuboCop::AST::NodePattern.new(pattern).match(node)
        end

        def magic_number_optional_argument_pattern
          MAGIC_NUMBER_OPTIONAL_ARGUMENT_PATTERN.call(illegal_scalar_types_ast:)
        end

        def illegal_positional_default?(node)
          node_matches_pattern?(node:, pattern: magic_number_optional_argument_pattern)
        end

        def magic_number_argument_pattern
          MAGIC_NUMBER_ARGUMENT_PATTERN.call(illegal_scalar_types_ast:)
        end

        def illegal_argument?(node)
          node_matches_pattern?(node:, pattern: magic_number_argument_pattern)
        end

        def illegal_scalar_types
          ILLEGAL_SCALAR_TYPES[cop_config['ForbiddenNumerics'] || 'All']
        end

        def illegal_scalar_types_ast
          "{#{illegal_scalar_types.join(' ')}}"
        end
      end
    end
  end
end
