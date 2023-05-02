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
    ASSIGNS_VIA_ATTR_WRITER_PATTERN = '(send ({send self} ... ) _ (${int float} _))'
    LOCAL_VARIABLE_ASSIGN_MSG = 'Do not use magic number local variables'
    INSTANCE_VARIABLE_ASSIGN_MSG = 'Do not use magic number instance variables'
    SEND_METHOD_MSG = 'Do not use magic numbers to set properties'

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

      add_offense(node, location: :expression, message: SEND_METHOD_MSG)
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
      return false unless RuboCop::AST::NodePattern.new(ASSIGNS_VIA_ATTR_WRITER_PATTERN).match(node)

      value = node.children.last
      ILLEGAL_SCALAR_TYPES.include?(value.type)
    end
  end
end
