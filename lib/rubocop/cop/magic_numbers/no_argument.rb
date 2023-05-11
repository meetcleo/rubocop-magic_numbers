# frozen_string_literal: true

require_relative 'base'

module RuboCop
  module Cop
    module MagicNumbers
      # Adds violations for magic numbers, when used as default values for
      # arguments to methods
      #
      # bad: def on_the_wall(bottles = 100)
      #
      # good: def on_the_wall(bottles = DEFAULT_BOTTLE_COUNT)
      class NoArgument < Base
        MAGIC_NUMBER_OPTIONAL_ARGUMENT_PATTERN = <<-PATTERN
          (def
            _
            (args
              <({kwoptarg optarg}
                _
                (%<illegal_scalar_pattern>s _)
              ) ...>
            )
            ...
          )
        PATTERN

        MAGIC_NUMBER_ARGUMENT_PATTERN = <<-PATTERN
          (send
            {
              _
              _
              (%<illegal_scalar_pattern>s _)
              | # This is a union of lhs and rhs literal
              (%<illegal_scalar_pattern>s _)
              _
              _
            }
          )
        PATTERN

        DEFAULT_OPTIONAL_ARGUMENT_MSG = 'Do not use magic number optional ' \
                                        'argument defaults'

        ARGUMENT_MSG = 'Do not use magic number arguments to methods'

        CONFIG_IGNORED_METHODS_NAME = 'IgnoredMethods'

        # By default, don't raise an offense for magic numbers arguments
        # for these methods
        DEFAULT_CONFIG = {
          CONFIG_IGNORED_METHODS_NAME => ['[]']
        }.freeze

        def cop_config
          super.merge(DEFAULT_CONFIG)
        end

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
          return if ignored_method?(node)

          add_offense(node, location: :expression, message: ARGUMENT_MSG)
        end
        alias on_send on_message_send # rubocop API method name

        private

        def ignored_method?(node)
          return false unless node.respond_to?(:method_name)

          ignored_methods.include?(node.method_name)
        end

        def ignored_methods
          Array(cop_config[CONFIG_IGNORED_METHODS_NAME]).map(&:to_sym)
        end

        def illegal_positional_default?(node)
          node_matches_pattern?(
            node:,
            pattern: format(
              MAGIC_NUMBER_OPTIONAL_ARGUMENT_PATTERN,
              illegal_scalar_pattern:
            )
          )
        end

        def illegal_argument?(node)
          node_matches_pattern?(
            node:,
            pattern: format(
              MAGIC_NUMBER_ARGUMENT_PATTERN,
              illegal_scalar_pattern:
            )
          )
        end
      end
    end
  end
end
