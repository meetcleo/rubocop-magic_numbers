# frozen_string_literal: true

module Custom
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
    MAGIC_NUMBER_ARGUMENT_PATTERN = "(send ({send self} ... ) _ (${#{ILLEGAL_SCALAR_TYPES.join(' ')}} _))".freeze
    LOCAL_VARIABLE_ASSIGN_MSG = 'Do not use magic number local variables'
    INSTANCE_VARIABLE_ASSIGN_MSG = 'Do not use magic number instance variables'
    PROPERTY_MSG = 'Do not use magic numbers to set properties'
    UNARY_MSG = 'Do not use magic numbers in unary methods'
    UNARY_LENGTH = 1

    def on_local_variable_assignment(node)
      return unless magic_number_local_variable?(node)

      add_offense(node, location: :expression, message: LOCAL_VARIABLE_ASSIGN_MSG)
    end
    alias on_lvasgn on_local_variable_assignment # rubocop API method name


    def on_instance_variable_assignment(node)
      return unless magic_number_instance_variable?(node)

      add_offense(node, location: :expression, message: INSTANCE_VARIABLE_ASSIGN_MSG)
    end
    alias on_ivasgn on_instance_variable_assignment # rubocop API method name

    def on_message_send(node)
      return unless magic_number_setter_assign?(node)

      if assignment?(node)
        add_offense(node, location: :expression, message: PROPERTY_MSG)
      elsif unary?(node)
        add_offense(node, location: :expression, message: UNARY_MSG)
      end
    end
    alias on_send on_message_send # rubocop API method name

    private

    def magic_number_local_variable?(node)
      return false unless node.lvasgn_type?

      value = node.children.last
      ILLEGAL_SCALAR_TYPES.include?(value.type)
    end

    def magic_number_instance_variable?(node)
      return false unless node.ivasgn_type?

      value = node.children.last
      ILLEGAL_SCALAR_TYPES.include?(value.type)
    end

    def magic_number_setter_assign?(node)
      return false unless node.send_type?

      RuboCop::AST::NodePattern.new(MAGIC_NUMBER_ARGUMENT_PATTERN).match(node)
    end

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

    def method_name(node)
      node.to_a[1]
    end
  end
end
