# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'
require 'rubocop/no_magic_numbers'

module RuboCop
  module Cop
    module MagicNumbers
      class NoArgument
        module Integer
          class MethodTest < Minitest::Test
            def test_detects_magic_numbers_used_as_arguments_to_methods
              matched_numerics.each do |num|
                inspect_source(<<~RUBY)
                  foo(#{num})
                RUBY

                assert_argument_offense
              end
            end

            def test_detects_magic_numbers_used_as_implicit_arguments_to_methods
              matched_numerics.each do |num|
                inspect_source(<<~RUBY)
                  foo #{num}
                RUBY

                assert_argument_offense
              end
            end

            def test_detects_magic_numbers_used_on_left_of_operators
              matched_numerics.each do |num|
                inspect_source(<<~RUBY)
                  #{num} + foo
                RUBY

                assert_argument_offense
              end
            end

            def test_detects_magic_numbers_used_on_right_of_operators
              matched_numerics.each do |num|
                inspect_source(<<~RUBY)
                  foo + #{num}
                RUBY

                assert_argument_offense
              end
            end

            private

            def assert_argument_offense
              assert_offense(
                cop_name: cop.name,
                violation_message: described_class::ARGUMENT_MSG
              )
            end

            def matched_numerics
              TestHelper::INTEGER_LITERALS
            end

            def described_class
              RuboCop::Cop::MagicNumbers::NoArgument
            end

            def cop
              @cop ||= described_class.new(config)
            end

            def config
              @config ||= RuboCop::Config.new(
                'MagicNumbers/NoArgument' => {
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
