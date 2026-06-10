# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'

module RuboCop
  module Cop
    module MagicNumbers
      class NoAssignment
        class PermittedValuesTest < Minitest::Test
          def test_permitted_values_defaults_to_empty
            default_config = RuboCop::Config.new('MagicNumbers/NoAssignment' => { 'Enabled' => true })

            assert_empty(described_class.new(default_config).cop_config['PermittedValues'])
          end

          def test_allows_permitted_values_assigned_to_variables_and_properties
            inspect_source(<<~RUBY)
              def test_method
                local_variable = 0
                @instance_variable = 1
                self.property = 0.0
                first, second = 0, 1
              end
            RUBY

            assert_no_offenses
          end

          def test_detects_unpermitted_local_variable_assignment
            inspect_source(<<~RUBY)
              def test_method
                local_variable = 10
              end
            RUBY

            assert_offense(
              cop_name: cop.name,
              violation_message: described_class::LOCAL_VARIABLE_ASSIGN_MSG
            )
          end

          def test_detects_unpermitted_instance_variable_assignment
            inspect_source(<<~RUBY)
              def test_method
                @instance_variable = 10
              end
            RUBY

            assert_offense(
              cop_name: cop.name,
              violation_message: described_class::INSTANCE_VARIABLE_ASSIGN_MSG
            )
          end

          def test_detects_unpermitted_property_assignment
            inspect_source(<<~RUBY)
              def test_method
                self.property = 10
              end
            RUBY

            assert_offense(
              cop_name: cop.name,
              violation_message: described_class::PROPERTY_MSG
            )
          end

          def test_detects_multiple_assignment_when_unpermitted_value_follows_permitted_value
            inspect_source(<<~RUBY)
              def test_method
                first, second = 0, 2
              end
            RUBY

            assert_multiple_assignment_offense
          end

          def test_detects_multiple_assignment_when_unpermitted_value_precedes_permitted_value
            inspect_source(<<~RUBY)
              def test_method
                first, second = 2, 0
              end
            RUBY

            assert_multiple_assignment_offense
          end

          def test_detects_multiple_assignment_when_values_are_wrapped_in_array
            inspect_source(<<~RUBY)
              def test_method
                first, second = [0, 2]
              end
            RUBY

            assert_multiple_assignment_offense
          end

          def test_allows_multiple_assignment_when_wrapped_array_values_are_permitted
            inspect_source(<<~RUBY)
              def test_method
                first, second = [0, 1]
              end
            RUBY

            assert_no_offenses
          end

          def test_allows_permitted_float_assignment
            @config = RuboCop::Config.new(
              'MagicNumbers/NoAssignment' => {
                'Enabled' => true,
                'PermittedValues' => [3.14]
              }
            )
            @cop = described_class.new(config)

            inspect_source(<<~RUBY)
              def test_method
                local_variable = 3.14
                @instance_variable = 3.14
                self.property = 3.14
                first, second = 3.14, 3.14
              end
            RUBY

            assert_no_offenses
          end

          def test_ignores_index_assignment
            inspect_source(<<~RUBY)
              def test_method
                values[0] = 1
              end
            RUBY

            assert_no_offenses
          end

          private

          def assert_multiple_assignment_offense
            assert_offense(
              cop_name: cop.name,
              violation_message: described_class::MULTIPLE_ASSIGN_MSG
            )
          end

          def described_class
            RuboCop::Cop::MagicNumbers::NoAssignment
          end

          def cop
            @cop ||= described_class.new(config)
          end

          def config
            @config ||= RuboCop::Config.new(
              'MagicNumbers/NoAssignment' => {
                'Enabled' => true,
                'PermittedValues' => [0, 1]
              }
            )
          end
        end
      end
    end
  end
end
