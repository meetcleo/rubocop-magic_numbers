# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'

module RuboCop
  module Cop
    module MagicNumbers
      class NoAssignment
        class InstanceVariableTest < Minitest::Test
          def test_ignores_magic_numbers_assigned_to_ivars_outside_of_methods
            matched_numerics.each do |num|
              inspect_source(<<~RUBY)
                @instance_variable = #{num}
              RUBY

              assert_no_offenses
            end
          end

          def test_detects_magic_numbers_assigned_to_instance_variables
            matched_numerics.each do |num|
              inspect_source(<<~RUBY)
                def test_method
                  @instance_variable = #{num}
                end
              RUBY

              assert_instance_variable_offense
            end
          end

          private

          def assert_instance_variable_offense
            assert_offense(
              cop_name: cop.name,
              violation_message: described_class::INSTANCE_VARIABLE_ASSIGN_MSG
            )
          end

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
