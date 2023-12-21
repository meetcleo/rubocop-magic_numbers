# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'

module RuboCop
  module Cop
    module MagicNumbers
      class NoArgument
        module Integer
          class MethodTest < Minitest::Test
            ARBITRARY_INTEGER_TO_PERMIT = 5

            def test_detects_magic_numbers_used_as_arguments_to_methods
              matched_numerics(:integer).each do |num|
                inspect_source(<<~RUBY)
                  foo(#{num})
                RUBY

                assert_argument_offense
              end
            end

            def test_detects_magic_numbers_used_as_implicit_arguments_to_methods
              matched_numerics(:integer).each do |num|
                inspect_source(<<~RUBY)
                  foo #{num}
                RUBY

                assert_argument_offense
              end
            end

            def test_detects_magic_numbers_used_on_left_of_operators
              matched_numerics(:integer).each do |num|
                inspect_source(<<~RUBY)
                  #{num} + foo
                RUBY

                assert_argument_offense
              end
            end

            def test_detects_magic_numbers_used_on_right_of_operators
              matched_numerics(:integer).each do |num|
                inspect_source(<<~RUBY)
                  foo + #{num}
                RUBY

                assert_argument_offense
              end
            end

            # Explicitly tests this popular use case
            def test_allows_magic_integers_permitted_in_config_used_with_increment
              inspect_source(<<~RUBY)
                foo += #{ARBITRARY_INTEGER_TO_PERMIT}
              RUBY

              assert_no_offenses
            end

            def test_allows_magic_integers_permitted_in_config_when_left_operand
              @config = RuboCop::Config.new({
                                              'MagicNumbers/NoArgument' => {
                                                'PermittedValues' => [ARBITRARY_INTEGER_TO_PERMIT]
                                              }
                                            })
              @cop = described_class.new(config)

              inspect_source(<<~RUBY)
                #{ARBITRARY_INTEGER_TO_PERMIT} + bar
              RUBY

              assert_no_offenses(cop_name:)
            end

            def test_allows_magic_integers_permitted_in_config_when_right_operand
              @config = RuboCop::Config.new({
                                              'MagicNumbers/NoArgument' => {
                                                'PermittedValues' => [ARBITRARY_INTEGER_TO_PERMIT]
                                              }
                                            })
              @cop = described_class.new(config)

              inspect_source(<<~RUBY)
                foo + #{ARBITRARY_INTEGER_TO_PERMIT}
              RUBY

              assert_no_offenses(cop_name:)
            end

            def test_allows_magic_integers_permitted_in_config_as_positional_arg
              @config = RuboCop::Config.new({
                                              'MagicNumbers/NoArgument' => {
                                                'PermittedValues' => [ARBITRARY_INTEGER_TO_PERMIT]
                                              }
                                            })
              @cop = described_class.new(config)

              inspect_source(<<~RUBY)
                object.call(#{ARBITRARY_INTEGER_TO_PERMIT})
              RUBY

              assert_no_offenses(cop_name:)
            end

            def test_allows_magic_integers_permitted_in_config_as_keyword_arg
              @config = RuboCop::Config.new({
                                              'MagicNumbers/NoArgument' => {
                                                'PermittedValues' => []
                                              }
                                            })
              @cop = described_class.new(config)

              inspect_source(<<~RUBY)
                object.call(val: #{ARBITRARY_INTEGER_TO_PERMIT})
              RUBY

              assert_no_offenses(cop_name:)
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

            def cop_name
              cop.cop_name
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
