# frozen_string_literal: true

require_relative 'base'

module RuboCop
  module Cop
    module MagicNumbers
      # Adds violations for magic numbers, when used as default values for
      # arguments to methods
      #
      # BAD
      # def on_the_wall(bottles = 100)
      #
      # GOOD
      # def on_the_wall(bottles = DEFAULT_BOTTLE_COUNT)
      class NoDefault < RuboCop::Cop::MagicNumbers::Base
        MAGIC_NUMBER_OPTIONAL_ARGUMENT_PATTERN = <<-PATTERN
          (def
            _
            (args
              <({kwoptarg optarg}
                _
                (%<illegal_scalar_pattern>s _)
              ) ...>
            )
            ...
          )
        PATTERN

        DEFAULT_OPTIONAL_ARGUMENT_MSG = 'Do not use magic number optional ' \
                                        'argument defaults'

        def on_method_defined(node)
          return unless illegal_positional_default?(node)

          add_offense(
            node,
            message: DEFAULT_OPTIONAL_ARGUMENT_MSG
          )
        end
        alias on_def on_method_defined # rubocop API method name

        private

        def illegal_positional_default?(node)
          node_matches_pattern?(
            node: node,
            pattern: format(
              MAGIC_NUMBER_OPTIONAL_ARGUMENT_PATTERN,
              illegal_scalar_pattern: illegal_scalar_pattern
            )
          )
        end
      end
    end
  end
end
