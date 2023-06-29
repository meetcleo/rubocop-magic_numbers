# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'

module RuboCop
  module Cop
    module MagicNumbers
      class NoArgument
        module Float
          class MethodTest < Minitest::Test
            ARBITRARY_FLOAT_TO_PERMIT = 3.14

            def test_detects_magic_numbers_used_as_arguments_to_methods
              matched_numerics(:float).each do |num|
                inspect_source(<<~RUBY)
                  foo(#{num})
                RUBY

                assert_argument_offense
              end
            end

            def test_detects_magic_numbers_used_as_implicit_arguments_to_methods
              matched_numerics(:float).each do |num|
                inspect_source(<<~RUBY)
                  foo #{num}
                RUBY

                assert_argument_offense
              end
            end

            def test_detects_magic_numbers_used_on_left_of_operators
              matched_numerics(:float).each do |num|
                inspect_source(<<~RUBY)
                  #{num} + foo
                RUBY

                assert_argument_offense
              end
            end

            def test_detects_magic_numbers_used_on_right_of_operators
              matched_numerics(:float).each do |num|
                inspect_source(<<~RUBY)
                  foo + #{num}
                RUBY

                assert_argument_offense
              end
            end

            def test_allows_magic_floats_permitted_in_config_when_left_operand
              @config = RuboCop::Config.new({
                                              'MagicNumbers/NoArgument' => {
                                                'PermittedValues' => [ARBITRARY_FLOAT_TO_PERMIT]
                                              }
                                            })
              @cop = described_class.new(config)

              inspect_source(<<~RUBY)
                #{ARBITRARY_FLOAT_TO_PERMIT} + bar
              RUBY

              assert_no_offenses('MagicNumbers/NoArgument')
            end

            def test_allows_magic_floats_permitted_in_config_when_right_operand
              @config = RuboCop::Config.new({
                                              'MagicNumbers/NoArgument' => {
                                                'PermittedValues' => [ARBITRARY_FLOAT_TO_PERMIT]
                                              }
                                            })
              @cop = described_class.new(config)

              inspect_source(<<~RUBY)
                foo + #{ARBITRARY_FLOAT_TO_PERMIT}
              RUBY

              assert_no_offenses('MagicNumbers/NoArgument')
            end

            def test_allows_magic_floats_permitted_in_config_as_positional_arg
              @config = RuboCop::Config.new({
                                              'MagicNumbers/NoArgument' => {
                                                'PermittedValues' => [ARBITRARY_FLOAT_TO_PERMIT]
                                              }
                                            })
              @cop = described_class.new(config)

              inspect_source(<<~RUBY)
                object.call(#{ARBITRARY_FLOAT_TO_PERMIT})
              RUBY

              assert_no_offenses('MagicNumbers/NoArgument')
            end

            def test_allows_magic_floats_permitted_in_config_as_keyword_arg
              @config = RuboCop::Config.new({
                                              'MagicNumbers/NoArgument' => {
                                                'PermittedValues' => [ARBITRARY_FLOAT_TO_PERMIT]
                                              }
                                            })
              @cop = described_class.new(config)

              inspect_source(<<~RUBY)
                object.call(val: #{ARBITRARY_FLOAT_TO_PERMIT})
              RUBY

              assert_no_offenses('MagicNumbers/NoArgument')
            end

            private

            def assert_argument_offense
              assert_offense(
                cop_name: cop.name,
                violation_message: described_class::ARGUMENT_MSG
              )
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
