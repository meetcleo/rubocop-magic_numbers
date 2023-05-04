# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'
require 'rubocop/no_magic_numbers'

module RuboCop
  module Cop
    module MagicNumbers
      class NoAssignment
        class GlobalVariableTest < Minitest::Test
          def test_ignores_magic_numbers_assigned_to_global_variables_by_default
            cop_class = described_class.new(config)

            allowed_assignments = cop_class.cop_config['AllowedAssignments']

            assert_includes(allowed_assignments, 'global_variables')
          end

          private

          def described_class
            RuboCop::Cop::MagicNumbers::NoAssignment
          end

          def cop
            @cop ||= described_class.new(config)
          end

          def config
            @config ||= RuboCop::Config.new('MagicNumbers/NoAssignment' => { 'Enabled' => true })
          end
        end
      end
    end
  end
end
