# frozen_string_literal: true

require 'test_helper'
require 'rubocop/cop/magic_numbers/no_return'

module RuboCop
  module Cop
    module MagicNumbers
      module Float
        class NoReturnTest < ::Minitest::Test
          def test_when_a_method_explicitly_returns_a_float
            matched_numerics(:float).each do |num|
              inspect_source(<<~RUBY)
                def test_method
                  return #{num}
                end
              RUBY

              assert_offense(
                cop_name:,
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
                cop_name:,
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
                cop_name:,
                violation_message: described_class::NO_EXPLICIT_RETURN_MSG
              )
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
