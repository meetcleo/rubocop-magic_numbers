# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'
require 'custom/no_magic_numbers'

module Custom
  module Configuration
    module Integers
      class MatchedTest < Minitest::Test
        def setup
          @config = RuboCop::Config.new('Custom/NoMagicNumbers' => { 'Enabled' => true, 'ForbiddenNumerics' => 'Integer' })

          # We detect only integers, so this is used in tests to check for all
          # combinations of representations of integers. The string
          # numeric representation is to ensure matching still happens when only
          # one numeric is present in a multiassignment
          integers = %w[10 1_0]
          number_string = ["'1'"]
          @matched_numerics = (integers + number_string).combination(2).to_a
        end

        def test_detects_magic_numbers_multiassigned_to_local_variables
          @matched_numerics.each do |nums|
            inspect_source(<<~RUBY)
              def test_method
                first_local_variable, second_local_variable = #{nums.join(', ')}
              end
            RUBY

            assert_multiple_assignment_test
          end
        end

        def test_detects_magic_numbers_multiassigned_to_instance_variables
          @matched_numerics.each do |nums|
            inspect_source(<<~RUBY)
              def test_method
                @first_instance_variable, @second_instance_variable = #{nums.join(', ')}
              end
            RUBY

            assert_multiple_assignment_test
          end
        end

        def test_detects_magic_numbers_multiassigned_via_attr_writers_on_self
          @matched_numerics.each do |nums|
            inspect_source(<<~RUBY)
              def test_method
                self.first_mutli_test_attr_writer, self.second_mutli_test_attr_writer = #{nums.join(', ')}
              end
            RUBY

            assert_multiple_assignment_test
          end
        end

        def test_detects_magic_numbers_multiassigned_via_attr_writers_on_another_object
          @matched_numerics.each do |nums|
            inspect_source(<<~RUBY)
              def test_method
                foo.first_mutli_test_attr_writer, foo.second_mutli_test_attr_writer = #{nums.join(', ')}
              end
            RUBY

            assert_multiple_assignment_test
          end
        end

        private

        def assert_multiple_assignment_test
          assert_offense(
            cop_name: cop.name,
            violation_message: described_class::MULTIPLE_ASSIGN_MSG
          )
        end

        def described_class
          Custom::NoMagicNumbers
        end

        def cop
          @cop ||= described_class.new(config)
        end
      end
    end
  end
end
