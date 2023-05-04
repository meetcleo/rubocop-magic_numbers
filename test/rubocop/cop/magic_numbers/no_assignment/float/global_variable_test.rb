# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'
require 'rubocop/no_magic_numbers'

module RuboCop
  module Cop
    module MagicNumbers
      class NoAssignment
        module Float
          class GlobalVariableTest < Minitest::Test
            def setup
              @matched_numerics = TestHelper::FLOAT_LITERALS
            end

            def test_ignores_magic_numbers_assigned_to_global_variables
              @matched_numerics.each do |num|
                inspect_source(<<~RUBY)
                  def test_method
                    $GLOBAL_VARIABLE = #{num}
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
              @config ||= RuboCop::Config.new(
                'MagicNumbers/NoAssignment' => {
                  'Enabled' => true,
                  'ForbiddenNumerics' => 'Float'
                }
              )
            end
          end
        end
      end
    end
  end
end
