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
    LVASGN_MSG = 'Do not use magic number local variables'
    IVASGN_MSG = 'Do not use magic number instance variables'
    SEND_MSG = 'Do not use magic numbers to set properties'

    def on_local_variable_assignment(node)
      return unless magic_number_local_variable?(node)

      add_offense(node, location: :expression, message: LVASGN_MSG)
    end
    alias on_lvasgn on_local_variable_assignment


    def on_instance_variable_assignment(node)
      return unless magic_number_instance_variable?(node)

      add_offense(node, location: :expression, message: IVASGN_MSG)
    end
    alias on_ivasgn on_instance_variable_assignment

    def on_message_send(node)
      return unless anonymous_setter_assign?(node)

      add_offense(node, location: :expression, message: SEND_MSG)
    end
    alias on_send on_message_send

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

    def anonymous_setter_assign?(node)
      return false unless node.send_type?
      return false unless RuboCop::AST::NodePattern.new(ASSIGNS_VIA_ATTR_WRITER_PATTERN).match(node)

      value = node.children.last
      ILLEGAL_SCALAR_TYPES.include?(value.type)
    end
  end
end
