# frozen_string_literal: true

require_relative 'base'

module RuboCop
  module Cop
    module MagicNumbers
      # Adds violations for magic numbers, aka assignments to variables with
      # bare numbers, configurable by literal type. Can detect local, instance,
      # global, and setter assignment, and works on multiple assignment.
      #
      # bad: hours = 24
      #
      # good: HOURS_IN_ONE_DAY = 24
      class NoAssignment < RuboCop::Cop::MagicNumbers::Base
        MAGIC_NUMBER_ARGUMENT_TO_SETTER_PATTERN = <<-PATTERN
          (send
            ({send self} ...)
            $_
            (%<illegal_scalar_pattern>s _)
          )
        PATTERN

        MAGIC_NUMBER_MULTI_ASSIGN_PATTERN = <<-PATTERN
          (masgn
            (mlhs ({lvasgn ivasgn send} ...)+)
            (array <(%<illegal_scalar_pattern>s _) ...>)
          )
        PATTERN
        LOCAL_VARIABLE_ASSIGN_MSG = 'Do not use magic number local variables'
        INSTANCE_VARIABLE_ASSIGN_MSG = 'Do not use magic number instance variables'
        MULTIPLE_ASSIGN_MSG = 'Do not use magic numbers in multiple assignments'
        PROPERTY_MSG = 'Do not use magic numbers to set properties'
        DEFAULT_CONFIG = {
          'AllowedAssignments' => %w[class_variables global_variables]
        }.freeze

        def cop_config
          DEFAULT_CONFIG.merge(super)
        end

        def on_local_variable_assignment(node)
          return unless illegal_scalar_value?(node)
          return unless node_within_method?(node)

          add_offense(node, message: LOCAL_VARIABLE_ASSIGN_MSG)
        end
        alias on_lvasgn on_local_variable_assignment # rubocop API method name

        def on_instance_variable_assignment(node)
          return unless illegal_scalar_value?(node)
          return unless node_within_method?(node)

          add_offense(node, message: INSTANCE_VARIABLE_ASSIGN_MSG)
        end
        alias on_ivasgn on_instance_variable_assignment # rubocop API method name

        def on_message_send(node)
          return unless illegal_scalar_argument_to_setter?(node)
          return unless node_within_method?(node)

          add_offense(node, message: PROPERTY_MSG)
        end
        alias on_send on_message_send # rubocop API method name

        def on_multiple_assign(node)
          # multiassignment nodes aren't AsgnNode typed, so we need to have a
          # special approach to deconstruct them and assess if they contain magic
          # numbers amongst their assignments
          return false unless illegal_multi_assign_right_hand_side?(node)

          add_offense(node, message: MULTIPLE_ASSIGN_MSG)
        end
        alias on_masgn on_multiple_assign

        private

        def illegal_scalar_argument_to_setter?(node)
          method = node_matches_pattern?(
            node: node,
            pattern: format(
              MAGIC_NUMBER_ARGUMENT_TO_SETTER_PATTERN,
              illegal_scalar_pattern: illegal_scalar_pattern
            )
          )

          method&.end_with?('=')
        end

        def illegal_multi_assign_right_hand_side?(node)
          node_matches_pattern?(
            node: node,
            pattern: format(
              MAGIC_NUMBER_MULTI_ASSIGN_PATTERN,
              illegal_scalar_pattern: illegal_scalar_pattern
            )
          )
        end

        def illegal_scalar_value?(node)
          return false unless node.assignment?

          # multiassignment nodes contain individual assignments in their AST
          # representations, but they aren't aware of their values, so we need to
          # allow for expressionless assignments
          forbidden_numerics.include?(node.expression&.type)
        end
      end
    end
  end
end
