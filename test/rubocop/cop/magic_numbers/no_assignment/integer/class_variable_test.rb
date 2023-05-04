# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'

module RuboCop
  module Cop
    module MagicNumbers
      class NoAssignment
        module Integer
          class ClassVariableTest < Minitest::Test
            def setup
              @matched_numerics = TestHelper::INTEGER_LITERALS
            end

            def test_ignores_magic_numbers_assigned_to_class_variables
              @matched_numerics.each do |num|
                inspect_source(<<~RUBY)
                  def test_method
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
