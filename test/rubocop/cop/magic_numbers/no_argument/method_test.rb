# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'

module RuboCop
  module Cop
    module MagicNumbers
      class NoArgument
        class MethodTest < Minitest::Test
          def test_ignores_methods_in_ignored_methods_config
            @config = RuboCop::Config.new({
                                            'MagicNumbers/NoArgument' => {
                                              'Enabled' => true,
                                              'IgnoredMethods' => ['[]', 'ignored_method_name']
                                            }
                                          })
            @cop = described_class.new(config)

            assert_includes cop.cop_config['IgnoredMethods'], '[]'
            assert_includes cop.cop_config['IgnoredMethods'], 'ignored_method_name'

            matched_numerics.each do |num|
              inspect_source(<<~RUBY)
                ignored_method_name(#{num})
              RUBY

              assert_no_offenses
            end
          end

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

          def test_allows_magic_numbers_in_square_bracket_enum_index_arguments
            matched_numerics.each do |num|
              inspect_source(<<~RUBY)
                my_collection[#{num}]
              RUBY

              assert_no_offenses
            end
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
            @config ||= RuboCop::Config.new('MagicNumbers/NoArgument' => { 'Enabled' => true })
          end
        end
      end
    end
  end
end
