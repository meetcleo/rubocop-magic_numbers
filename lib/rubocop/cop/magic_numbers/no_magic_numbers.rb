# frozen_string_literal: true

module Rubocop
  module Cop
    module MagicNumbers
      # Adds violations for magic numbers, aka assignments to variables with bare
      # numbers (float or int)
      #
      # bad:
      # hours = 24
      #
      # good:
      # HOURS_IN_ONE_DAY = 24
      class NoMagicNumbers < ::RuboCop::Cop::Cop
        ILLEGAL_SCALAR_TYPES = %i[float int].freeze
        MAGIC_NUMBER_ARGUMENT_PATTERN = <<-PATTERN.freeze
          (send
            ({send self} ...)
            _
            (${#{ILLEGAL_SCALAR_TYPES.join(' ')}} _)
          )
        PATTERN
        MAGIC_NUMBER_MULTI_ASSIGN_PATTERN = <<-PATTERN.freeze
          (masgn
            (mlhs ({lvasgn ivasgn send} ...)+)
            (array <(${#{ILLEGAL_SCALAR_TYPES.join(' ')}} _) ...>)
          )
        PATTERN
        LOCAL_VARIABLE_ASSIGN_MSG = 'Do not use magic number local variables'
        INSTANCE_VARIABLE_ASSIGN_MSG = 'Do not use magic number instance variables'
        MULTIPLE_ASSIGN_MSG = 'Do not use magic numbers in multiple assignments'
        PROPERTY_MSG = 'Do not use magic numbers to set properties'
        UNARY_MSG = 'Do not use magic numbers in unary methods'
        UNARY_LENGTH = 1

        def on_local_variable_assignment(node)
          return unless illegal_scalar_value?(node)

          add_offense(node, location: :expression, message: LOCAL_VARIABLE_ASSIGN_MSG)
        end
        alias on_lvasgn on_local_variable_assignment # rubocop API method name

        def on_instance_variable_assignment(node)
          return unless illegal_scalar_value?(node)

          add_offense(node, location: :expression, message: INSTANCE_VARIABLE_ASSIGN_MSG)
        end
        alias on_ivasgn on_instance_variable_assignment # rubocop API method name

        def on_message_send(node)
          return unless illegal_scalar_argument?(node)

          if assignment?(node)
            add_offense(node, location: :expression, message: PROPERTY_MSG)
          elsif unary?(node)
            add_offense(node, location: :expression, message: UNARY_MSG)
          end
        end
        alias on_send on_message_send # rubocop API method name

        def on_multiple_assign(node)
          # multiassignment nodes aren't AsgnNode typed, so we need to have a
          # special approach to deconstruct them and assess if they contain magic
          # numbers amongst their assignments
          return false unless illegal_multi_assign_right_hand_side?(node)

          add_offense(node, location: :expression, message: MULTIPLE_ASSIGN_MSG)
        end
        alias on_masgn on_multiple_assign

        private

        def assignment?(node)
          # Only match on method names that resemble assignments
          method_name(node).end_with?('=')
        end

        def unary?(node)
          # Only match on method names that are unary invocations, so 1 character
          # long
          method_name(node).length == UNARY_LENGTH
        end

        def illegal_scalar_argument?(node)
          RuboCop::AST::NodePattern.new(MAGIC_NUMBER_ARGUMENT_PATTERN).match(node)
        end

        def illegal_multi_assign_right_hand_side?(node)
          RuboCop::AST::NodePattern.new(MAGIC_NUMBER_MULTI_ASSIGN_PATTERN).match(node)
        end

        def illegal_scalar_value?(node)
          return false unless node.assignment?

          # multiassignment nodes contain individual assignments in their AST
          # representations, but they aren't aware of their values, so we need to
          # allow for expressionless assignments
          ILLEGAL_SCALAR_TYPES.include?(node.expression&.type)
        end

        def method_name(node)
          node.to_a[1]
        end
      end
    end
  end
end
