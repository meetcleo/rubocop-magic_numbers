# frozen_string_literal: true

require_relative 'base'

module RuboCop
  module Cop
    module MagicNumbers
      # Raises an offense if a method returns with a magic number
      # Catches both explicit and implicit returns
      class NoReturn < RuboCop::Cop::MagicNumbers::Base
        MAGIC_NUMBER_RETURN_PATTERN = <<~PATTERN.chomp
          (%<illegal_scalar_pattern>s $_)
        PATTERN
        NO_EXPLICIT_RETURN_MSG = 'Do not return magic numbers from a method or proc'

        CONFIG_NAME_ALLOWED_RETURNS = 'AllowedReturns'
        CONFIG_NAME_PERMITTED_RETURN_VALUES = 'PermittedReturnValues'

        RETURN_TYPE_IMPLICIT = 'Implicit'
        RETURN_TYPE_EXPLICIT = 'Explicit'
        RETURN_TYPE_NONE = 'None'

        DEFAULT_CONFIG = {
          # Supported values are 'Explicit', 'Implicit', 'None'
          CONFIG_NAME_ALLOWED_RETURNS => [RETURN_TYPE_NONE],
          CONFIG_NAME_PERMITTED_RETURN_VALUES => []
        }.freeze

        def cop_config
          DEFAULT_CONFIG.merge(super)
        end

        def on_method_defined(node)
          return if allowed_returns.include?(RETURN_TYPE_IMPLICIT)
          return unless (captured_value = implicit_return?(node.children.last))
          return if permitted_return_values.include?(captured_value)

          add_offense(node.children.last, message: NO_EXPLICIT_RETURN_MSG)
        end
        alias on_def on_method_defined

        def on_return(node)
          return if allowed_returns.include?(RETURN_TYPE_EXPLICIT)
          return unless forbidden_numerics.include?(node.children.first&.type)
          return if permitted_return_values.include?(node.children.first&.value)

          add_offense(node.children.first, message: NO_EXPLICIT_RETURN_MSG)
        end

        private

        def allowed_returns
          Array(cop_config[CONFIG_NAME_ALLOWED_RETURNS])
        end

        def implicit_return?(node)
          is_node_begin_type = node.is_a?(RuboCop::AST::Node) && node.begin_type?
          return implicit_return?(node.children.last) if is_node_begin_type

          pattern = format(MAGIC_NUMBER_RETURN_PATTERN, {
                             illegal_scalar_pattern: illegal_scalar_pattern
                           })
          node_matches_pattern?(node: node, pattern: pattern)
        end

        def permitted_return_values
          Array(cop_config['PermittedReturnValues'])
        end
      end
    end
  end
end
