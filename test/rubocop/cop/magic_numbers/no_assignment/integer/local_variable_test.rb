# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'
require 'rubocop/no_magic_numbers'

module RuboCop
  module Cop
    module MagicNumbers
      class NoAssignment
        module Integer
          class LocalVariableTest < Minitest::Test
            def setup
              @matched_numerics = TestHelper::INTEGER_LITERALS
            end

            def test_detects_magic_numbers_assigned_to_local_variables
              @matched_numerics.each do |num|
                inspect_source(<<~RUBY)
                  def test_method
                    local_variable = #{num}
                  end
                RUBY

                assert_local_variable_offense

                reset_cop
              end
            end

            private

            def assert_local_variable_offense
              assert_offense(
                cop_name: cop.name,
                violation_message: described_class::LOCAL_VARIABLE_ASSIGN_MSG
              )
            end

            def described_class
              RuboCop::Cop::MagicNumbers::NoAssignment
            end

            def cop
              @cop ||= described_class.new(config)
            end

            def reset_cop
              @cop = nil
            end

            def config
              @config ||= RuboCop::Config.new(
                'MagicNumbers/NoAssignment' => {
                  'Enabled' => true,
                  'ForbiddenNumerics' => 'Integer'
                }
              )
            end
          end
        end
      end
    end
  end
end
