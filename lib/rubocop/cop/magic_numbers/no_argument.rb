# frozen_string_literal: true

require_relative 'base'

module RuboCop
  module Cop
    module MagicNumbers
      # Adds violations for magic numbers when used as the argument to a method
      #
      # BAD:
      # object.bottles_on_the_wall(100)
      #
      # GOOD:
      # object.bottles_on_the_wall(DEFAULT_BOTTLE_COUNT)
      class NoArgument < RuboCop::Cop::MagicNumbers::Base
        MAGIC_NUMBER_ARGUMENT_PATTERN = <<-PATTERN
          (send
            {
              _
              _
              (%<illegal_scalar_pattern>s $_)
              | # This is a union of lhs and rhs literal
              (%<illegal_scalar_pattern>s $_)
              _
              _
            }
          )
        PATTERN

        ARGUMENT_MSG = 'Do not use magic number arguments to methods'

        CONFIG_IGNORED_METHODS_NAME = 'IgnoredMethods'

        # By default, don't raise an offense for magic numbers arguments
        # for these methods
        DEFAULT_CONFIG = {
          CONFIG_IGNORED_METHODS_NAME => ['[]']
        }.freeze

        def cop_config
          DEFAULT_CONFIG.merge(super)
        end

        def on_message_send(node)
          return unless illegal_argument?(node)
          return if ignored_method?(node)

          add_offense(node, message: ARGUMENT_MSG)
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

        def illegal_argument?(node)
          captured_value = node_matches_pattern?(
            node: node,
            pattern: format(
              MAGIC_NUMBER_ARGUMENT_PATTERN,
              illegal_scalar_pattern: illegal_scalar_pattern
            )
          )
          captured_value && !permitted_values.include?(captured_value)
        end

        def permitted_values
          Array(cop_config['PermittedValues'])
        end
      end
    end
  end
end
