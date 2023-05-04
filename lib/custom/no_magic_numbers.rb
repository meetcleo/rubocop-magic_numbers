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
    MAGIC_NUMBER_RETURN_PATTERN = <<~PATTERN.freeze
      (return
        (${#{ILLEGAL_SCALAR_TYPES.join(' ')}}))
    PATTERN
    LOCAL_VARIABLE_ASSIGN_MSG = 'Do not use magic number local variables'
    INSTANCE_VARIABLE_ASSIGN_MSG = 'Do not use magic number instance variables'
    MAGIC_RETURNS_MSG = 'Do not return magic numbers from a method or proc'
    MULTIPLE_ASSIGN_MSG = 'Do not use magic numbers in multiple assignments'
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
      return unless magic_number_method_argument?(node)

      if assignment?(node)
        add_offense(node, location: :expression, message: PROPERTY_MSG)
      elsif return?(node)
        add_offense(node, location: :expression, message: MAGIC_RETURNS_MSG)
      elsif unary?(node)
        add_offense(node, location: :expression, message: UNARY_MSG)
      end
    end
    alias on_send on_message_send # rubocop API method name

    def on_multiple_assign(node)
      return false unless magic_number_multiple_assign?(node)

      add_offense(node, location: :expression, message: MULTIPLE_ASSIGN_MSG)
    end
    alias on_masgn on_multiple_assign

    def on_def(node)
      if returns_a_magic_number?(node) || ends_on_a_magic_number?(node)
        add_offense(node, location: :expression, message: MAGIC_RETURNS_MSG)
      end
    end

    private

    def ends_on_a_magic_number?(node)
      node_matches_pattern?(node:, pattern: "(def _ ... ({int float} _))")
    end

    def returns_a_magic_number?(node)
      ILLEGAL_SCALAR_TYPES.include?(return_type_for_node(node.body))
    end

    def return_type_for_node(node)
      node.each_child_node do |child_node|
        case child_node.type
        when :return
          return child_node.children[0].type
        when :begin
          return_type_for_node(child_node)
        else
          child_node.type
        end
      end
      nil
    end

    def magic_number_local_variable?(node)
      return false unless node.lvasgn_type?

      illegal_scalar_value?(node)
    end

    def magic_number_instance_variable?(node)
      return false unless node.ivasgn_type?

      illegal_scalar_value?(node)
    end

    def magic_number_multiple_assign?(node)
      return false unless node.masgn_type?

      # multiassignment nodes aren't AsgnNode typed, so we need to have a
      # special approach to deconstruct them and assess if they contain magic
      # numbers amongst their assignments
      illegal_multi_assign_right_hand_side?(node)
    end

    def magic_number_method_argument?(node)
      return false unless node.send_type?

      node_matches_pattern?(node:, pattern: MAGIC_NUMBER_ARGUMENT_PATTERN)
    end

    # Match explicit returns with magic numbers
    def return?(node)
      node_matches_pattern?(node:, pattern: MAGIC_NUMBER_RETURN_PATTERN)
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
      node_matches_pattern?(node:, pattern: MAGIC_NUMBER_ARGUMENT_PATTERN)
    end

    def illegal_multi_assign_right_hand_side?(node)
      node_matches_pattern?(node:, pattern: MAGIC_NUMBER_MULTI_ASSIGN_PATTERN)
    end

    def node_matches_pattern?(node:, pattern:)
      RuboCop::AST::NodePattern.new(pattern).match(node)
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
