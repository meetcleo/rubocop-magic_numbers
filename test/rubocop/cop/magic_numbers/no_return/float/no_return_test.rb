# frozen_string_literal: true

require 'test_helper'
require 'rubocop/cop/magic_numbers/no_return'

module RuboCop
  module Cop
    module MagicNumbers
      module Float
        class NoReturnTest < ::Minitest::Test
          ARBITRARY_FLOAT_TO_PERMIT = 5.0

          def test_when_a_method_explicitly_returns_a_float
            matched_numerics(:float).each do |num|
              inspect_source(<<~RUBY)
                def test_method
                  return #{num}
                end
              RUBY

              assert_offense(
                cop_name: cop_name,
                violation_message: described_class::NO_EXPLICIT_RETURN_MSG
              )
            end
          end

          def test_when_a_method_conditionally_returns_a_float_early
            matched_numerics(:float).each do |num|
              inspect_source(<<~RUBY)
                def test_method
                  return #{num} if condition

                  true
                end
              RUBY

              assert_offense(
                cop_name: cop_name,
                violation_message: described_class::NO_EXPLICIT_RETURN_MSG
              )
            end
          end

          def test_when_a_method_implicitly_returns_a_float
            matched_numerics(:float).each do |num|
              inspect_source(<<~RUBY)
                def test_method
                  #{num}
                end
              RUBY

              assert_offense(
                cop_name: cop_name,
                violation_message: described_class::NO_EXPLICIT_RETURN_MSG
              )
            end
          end

          def test_when_a_method_implicitly_returns_a_float_after_other_things
            matched_numerics(:float).each do |num|
              inspect_source(<<~RUBY)
                def test_method
                  do_some_things

                  #{num}
                end
              RUBY

              assert_offense(
                cop_name: cop_name,
                violation_message: described_class::NO_EXPLICIT_RETURN_MSG
              )
            end
          end

          def test_allows_implicit_return_of_a_float_when_config_set
            @config = RuboCop::Config.new({
                                            'MagicNumbers/NoReturn' => {
                                              'Enabled' => true,
                                              'ForbiddenNumerics' => 'Float',
                                              'AllowedReturns' => ['Implicit']
                                            }
                                          })
            @cop = described_class.new(config)

            matched_numerics(:float).each do |num|
              inspect_source(<<~RUBY)
                def test_method
                  #{num}
                end
              RUBY

              assert_no_offenses(cop_name: cop_name)
            end
          end

          def test_allows_explicit_return_of_a_float_when_config_set
            @config = RuboCop::Config.new({
                                            'MagicNumbers/NoReturn' => {
                                              'Enabled' => true,
                                              'ForbiddenNumerics' => 'Float',
                                              'AllowedReturns' => ['Explicit']
                                            }
                                          })
            @cop = described_class.new(config)

            matched_numerics(:float).each do |num|
              inspect_source(<<~RUBY)
                def test_method
                  return #{num}

                  other_method
                end
              RUBY

              assert_no_offenses(cop_name: cop_name)
            end
          end

          def test_allows_explicit_return_of_an_integer_when_config_set
            @config = RuboCop::Config.new({
                                            'MagicNumbers/NoReturn' => {
                                              'Enabled' => true,
                                              'ForbiddenNumerics' => 'Integer',
                                              'PermittedReturnValues' => [ARBITRARY_FLOAT_TO_PERMIT]
                                            }
                                          })
            @cop = described_class.new(config)

            inspect_source(<<~RUBY)
              def test_method
                return #{ARBITRARY_FLOAT_TO_PERMIT}

                #{ARBITRARY_FLOAT_TO_PERMIT}
              end
            RUBY

            assert_no_offenses(cop_name: cop_name)
          end

          private

          def described_class
            RuboCop::Cop::MagicNumbers::NoReturn
          end

          def cop
            @cop ||= described_class.new(config)
          end

          def cop_name
            cop.name
          end

          def config
            @config ||= RuboCop::Config.new('MagicNumbers/NoReturn' => {
                                              'Enabled' => true,
                                              'ForbiddenNumerics' => 'Float'
                                            })
          end
        end
      end
    end
  end
end
