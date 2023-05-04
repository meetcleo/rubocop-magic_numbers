# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'
require 'rubocop/no_magic_numbers'

module RuboCop
  module Cop
    module MagicNumbers
      class NoAssignment
        class GlobalVariableTest < Minitest::Test
          def test_config_defaults_to_allow_global_variables
            allowed_assignments = described_class.new(config).cop_config['AllowedAssignments']

            assert_include(allowed_assignments, 'global_variables')
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
