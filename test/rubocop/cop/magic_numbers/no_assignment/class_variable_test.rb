# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'

module RuboCop
  module Cop
    module MagicNumbers
      class NoAssignment
        class ClassVariableTest < Minitest::Test
          def test_ignores_magic_numbers_assigned_to_class_variables_in_default_config
            cop_class = described_class.new(config)

            allowed_assignments = cop_class.cop_config['AllowedAssignments']

            assert_includes(allowed_assignments, 'class_variables')
          end

          def test_ignores_magic_numbers_assigned_to_class_variables_by_default
            matched_numerics.each do |num|
              inspect_source(<<~RUBY)
                class TestClass
                  @@class_variable = #{num}
                end
              RUBY

              assert_no_offenses
            end
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
