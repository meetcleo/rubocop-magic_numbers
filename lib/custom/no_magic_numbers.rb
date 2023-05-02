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
    LVASGN_MSG = 'Do not use magic number local variables'
    IVASGN_MSG = 'Do not use magic number instance variables'
    PROPERTY_MSG = 'Do not use magic numbers to set properties'
    UNARY_MSG = 'Do not use magic numbers in unary methods'
    UNARY_LENGTH = 1

    def on_lvasgn(node)
      return unless magic_number_lvar?(node)

      add_offense(node, location: :expression, message: LVASGN_MSG)
    end

    def on_ivasgn(node)
      return unless magic_number_ivar?(node)

      add_offense(node, location: :expression, message: IVASGN_MSG)
    end

    def on_send(node)
      return unless illegal_scalar_argument?(node)

      if assignment?(node)
        add_offense(node, location: :expression, message: PROPERTY_MSG)
      elsif unary?(node)
        add_offense(node, location: :expression, message: UNARY_MSG)
      end
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
