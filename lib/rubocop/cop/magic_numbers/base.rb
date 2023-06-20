# frozen_string_literal: true

require 'rubocop'
require 'rubocop/cop/cop'
# rubocop:disable Lint/SuppressedException
# This is only available in newer versions of the RuboCop gem
begin
  require 'rubocop/cop/base'
rescue LoadError
end
# rubocop:enable Lint/SuppressedException

module RuboCop
  module Cop
    module MagicNumbers
      # Base class for all shared behaviour between these cops

      def self.best_base_class
        if ::RuboCop::Cop.const_defined?('Base')
          ::RuboCop::Cop::Base
        else
          ::RuboCop::Cop::Cop
        end
      end

      class Base < best_base_class
        CONFIG_ALL = 'All'
        CONFIG_FLOAT = 'Float'
        CONFIG_INTEGER = 'Integer'
        CONFIG_NAME_FORBIDDEN_NUMERICS = 'ForbiddenNumerics'

        DEFAULT_CONFIG = {
          CONFIG_NAME_FORBIDDEN_NUMERICS => CONFIG_ALL
        }.freeze

        ILLEGAL_SCALAR_TYPES = {
          CONFIG_ALL => %i[float int],
          CONFIG_INTEGER => %i[int],
          CONFIG_FLOAT => %i[float]
        }.freeze

        # The configuration for this cop, pre-set with defaults
        #
        # Returns Hash
        def cop_config
          DEFAULT_CONFIG.merge(super)
        end

        private

        # The AST pattern for the configured ForbiddenNumerics types.
        #
        # Examples
        #
        #   "{float int}"
        #
        # Returns String
        def illegal_scalar_pattern
          "{#{forbidden_numerics.join(' ')}}"
        end

        # The numeric types that are forbidden based on this cop's configuration
        #
        # Returns Array of Symbols
        def forbidden_numerics
          forbidden_numerics_key = cop_config[CONFIG_NAME_FORBIDDEN_NUMERICS]
          ILLEGAL_SCALAR_TYPES[forbidden_numerics_key]
        end

        # Check if the given AST node matches the given pattern
        #
        # node    - A RuboCop::AST::ProcessedSource
        # pattern - A RuboCop::AST::NodePattern
        #
        # Returns Boolean
        def node_matches_pattern?(node:, pattern:)
          RuboCop::AST::NodePattern.new(pattern).match(node)
        end

        # Check if the given AST node is within a method definition
        #
        # node    - A RuboCop::AST::ProcessedSource
        #
        # Returns Boolean
        def node_within_method?(node)
          node.ancestors.any?(&:def_type?)
        end
      end
    end
  end
end
