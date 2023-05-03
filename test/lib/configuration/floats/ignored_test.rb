# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'
require 'custom/no_magic_numbers'

module Custom
  module Configuration
    module Floats
      class Matches < Minitest::Test
        def setup
          @config = RuboCop::Config.new('Custom/NoMagicNumbers' => { 'Enabled' => true, 'ForbiddenNumerics' => 'Float' })

          # We detect only Floats, so this is used in tests to check for all
          # combinations of representations of integers. These should be ignored, as
          # our configuration is that we want to mark an offense only on Integers
          integers = %w[10 1_0]
          @ignored_numerics = integers.combination(2).to_a
        end

        def test_ignores_ignored_magic_numbers_multiassigned_to_local_variables
          @ignored_numerics.each do |nums|
            inspect_source(<<~RUBY)
              def test_method
                first_local_variable, second_local_variable = #{nums.join(', ')}
              end
            RUBY

            refute_multiple_assignment_test
          end
        end

        def test_ignores_ignored_magic_numbers_multiassigned_to_instance_variables
          @ignored_numerics.each do |nums|
            inspect_source(<<~RUBY)
              def test_method
                @first_instance_variable, @second_instance_variable = #{nums.join(', ')}
              end
            RUBY

            refute_multiple_assignment_test
          end
        end

        def test_ignores_ignored_magic_numbers_multiassigned_via_attr_writers_on_self
          @ignored_numerics.each do |nums|
            inspect_source(<<~RUBY)
              def test_method
                self.first_mutli_test_attr_writer, self.second_mutli_test_attr_writer = #{nums.join(', ')}
              end
            RUBY

            refute_multiple_assignment_test
          end
        end

        def test_ignores_ignored_magic_numbers_multiassigned_via_attr_writers_on_another_object
          @ignored_numerics.each do |nums|
            inspect_source(<<~RUBY)
              def test_method
                foo.first_mutli_test_attr_writer, foo.second_mutli_test_attr_writer = #{nums.join(', ')}
              end
            RUBY

            refute_multiple_assignment_test
          end
        end

        private

        def refute_multiple_assignment_test
          refute_offense(cop_name: cop.name)
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
