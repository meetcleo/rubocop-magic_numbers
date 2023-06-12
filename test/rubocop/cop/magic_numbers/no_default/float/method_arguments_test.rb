# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'

module RuboCop
  module Cop
    module MagicNumbers
      class NoDefault
        module Float
          class MethodArgumentsTest < Minitest::Test
            def test_detects_magic_numbers_used_as_positional_defaults
              matched_numerics(:float).each do |num|
                inspect_source(<<~RUBY)
                  def test_method(foo, arg = #{num})
                    use_the(arg)
                  end
                RUBY

                assert_default_argument_offense
              end
            end

            def test_detects_magic_numbers_used_as_keyword_defaults
              matched_numerics(:float).each do |num|
                inspect_source(<<~RUBY)
                  def test_method(foo:, arg: #{num})
                    use_the(arg)
                  end
                RUBY

                assert_default_argument_offense
              end
            end

            def test_detects_magic_numbers_used_as_both_defaults
              matched_numerics(:float).each do |num|
                inspect_source(<<~RUBY)
                  def test_method(foo = #{num}, arg: #{num})
                    use_the(arg)
                  end
                RUBY

                assert_default_argument_offense
              end
            end

            private

            def assert_default_argument_offense
              assert_offense(
                cop_name: cop.name,
                violation_message: described_class::DEFAULT_OPTIONAL_ARGUMENT_MSG
              )
            end

            def described_class
              RuboCop::Cop::MagicNumbers::NoDefault
            end

            def cop
              @cop ||= described_class.new(config)
            end

            def config
              @config ||= RuboCop::Config.new(
                'MagicNumbers/NoDefault' => {
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
