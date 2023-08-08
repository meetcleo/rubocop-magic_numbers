# frozen_string_literal: true

require 'test_helper'
require 'rubocop/cop/magic_numbers/no_return'

module RuboCop
  module Cop
    module MagicNumbers
      module Integer
        class NoReturnTest < ::Minitest::Test
          def test_when_a_method_explicitly_returns_an_integer
            matched_numerics(:integer).each do |num|
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

          def test_when_a_method_conditionally_returns_an_integer_early
            matched_numerics(:integer).each do |num|
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

          def test_when_a_method_implicitly_returns_an_integer
            matched_numerics(:integer).each do |num|
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

          def test_when_a_method_implicitly_returns_an_integer_after_other_things
            matched_numerics(:integer).each do |num|
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

          def test_allows_implicit_return_of_an_integer_when_config_set
            update_config({
                            'MagicNumbers/NoReturn' => {
                              'Enabled' => true,
                              'ForbiddenNumerics' => 'Integer',
                              'AllowedReturns' => ['Implicit']
                            }
                          })
            matched_numerics(:integer).each do |num|
              inspect_source(<<~RUBY)
                def test_method
                  #{num}
                end
              RUBY

              assert_no_offenses(cop_name: cop_name)
            end
          end

          def test_allows_explicit_return_of_an_integer_when_config_set
            update_config({
                            'MagicNumbers/NoReturn' => {
                              'Enabled' => true,
                              'ForbiddenNumerics' => 'Integer',
                              'AllowedReturns' => ['Explicit']
                            }
                          })
            matched_numerics(:integer).each do |num|
              inspect_source(<<~RUBY)
                def test_method
                  return #{num}

                  other_method
                end
              RUBY

              assert_no_offenses(cop_name: cop_name)
            end
          end

          private

          def described_class
            RuboCop::Cop::MagicNumbers::NoReturn
          end

          def cop
            @cop ||= described_class.new(config)
          end

          def cop_name
            cop.cop_name
          end

          def config
            @config ||= RuboCop::Config.new('MagicNumbers/NoReturn' => {
                                              'Enabled' => true,
                                              'ForbiddenNumerics' => 'Integer'
                                            })
          end
        end
      end
    end
  end
end
