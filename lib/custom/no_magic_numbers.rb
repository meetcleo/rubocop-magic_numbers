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
    MAGIC_NUMBER_ARGUMENT_PATTERN = '(send ({send self} ... ) _ (${int float} _))'
    LVASGN_MSG = 'Do not use magic number local variables'
    IVASGN_MSG = 'Do not use magic number instance variables'
    SEND_MSG = 'Do not use magic numbers to set properties'

    def on_lvasgn(node)
      return unless magic_number_lvar?(node)

      add_offense(node, location: :expression, message: LVASGN_MSG)
    end

    def on_ivasgn(node)
      return unless magic_number_ivar?(node)

      add_offense(node, location: :expression, message: IVASGN_MSG)
    end

    def on_send(node)
      return unless anonymous_setter_assign?(node)

      add_offense(node, location: :expression, message: SEND_MSG)
    end

    private

    def magic_number_lvar?(node)
      return false unless node.lvasgn_type?

      value = node.children.last
      ILLEGAL_SCALAR_TYPES.include?(value.type)
    end

    def magic_number_ivar?(node)
      return false unless node.ivasgn_type?

      value = node.children.last
      ILLEGAL_SCALAR_TYPES.include?(value.type)
    end

    def anonymous_setter_assign?(node)
      return false unless node.send_type?
      return false unless RuboCop::AST::NodePattern.new(MAGIC_NUMBER_ARGUMENT_PATTERN).match(node)

      _receiver_node, method_name, *_arg_nodes = *node
      # Only match on method names that resemble assignments
      return false unless method_name.end_with?('=')

      value = node.children.last
      ILLEGAL_SCALAR_TYPES.include?(value.type)
    end
  end
end
