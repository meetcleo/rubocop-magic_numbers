module Custom
  class NoMagicNumbers < ::RuboCop::Cop::Cop
    ILLEGAL_SCALAR_TYPES = %i[float int]

    LVASGN_MSG = "Do not use magic number local variables".freeze
    IVASGN_MSG = "Do not use magic number instance variables".freeze
    # SEND_MSG = "Do not use magic number properties".freeze

    def on_lvasgn(node)
      if magic_number_lvar?(node)
        add_offense(node, location: :expression, message: LVASGN_MSG)
      end
    end

    def on_ivasgn(node)
      if magic_number_ivar?(node)
        add_offense(node, location: :expression, message: IVASGN_MSG)
      end
    end

    def on_send(node)
      if anonymous_setter_assign?(node)
        add_offense(node, location: :expression, message: SEND_MSG)
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

      def anonymous_setter_assign?(node)
        return false unless node.send_type?
        return false unless RuboCop::AST::NodePattern.new("(send (send ... ) _ (${int float} _))").match(node)

        value = node.children.last
        ILLEGAL_SCALAR_TYPES.include?(value.type)
      end
  end
end