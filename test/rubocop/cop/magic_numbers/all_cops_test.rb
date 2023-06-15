# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'

module RuboCop
  module Cop
    module MagicNumbers
      # These tests are to ensure that when all cops are enabled, only the
      # intended cop marks an offense
      class AllCopsTest < Minitest::Test
        # rubocop:disable Minitest/MultipleAssertions
        def test_detects_magic_numbers_used_as_positional_defaults
          matched_numerics.each do |num|
            inspect_source(<<~RUBY, cops: all_cops)
              def test_method(foo, arg = #{num})
                use_the(arg)
              end
            RUBY

            assert_offense(
              cop_name: no_default_cop.name,
              violation_message: no_default_cop.class::DEFAULT_OPTIONAL_ARGUMENT_MSG
            )
            assert_no_offenses(cop_name: no_argument_cop)
            assert_no_offenses(cop_name: no_assignment_cop)
            assert_no_offenses(cop_name: no_return_cop)
          end
        end

        def test_detects_magic_numbers_used_as_kwarg_defaults
          matched_numerics.each do |num|
            inspect_source(<<~RUBY, cops: all_cops)
              def test_method(foo, arg: #{num})
                use_the(arg)
              end
            RUBY

            assert_offense(
              cop_name: no_default_cop.name,
              violation_message: no_default_cop.class::DEFAULT_OPTIONAL_ARGUMENT_MSG
            )
            assert_no_offenses(cop_name: no_argument_cop)
            assert_no_offenses(cop_name: no_assignment_cop)
            assert_no_offenses(cop_name: no_return_cop)
          end
        end

        def test_detects_magic_numbers_assigned_to_local_variables
          matched_numerics.each do |num|
            inspect_source(<<~RUBY, cops: all_cops)
              def test_method
                set_attribute = #{num}
              end
            RUBY

            assert_no_offenses(cop_name: no_argument_cop)
            assert_offense(
              cop_name: no_assignment_cop.name,
              violation_message: no_assignment_cop.class::LOCAL_VARIABLE_ASSIGN_MSG
            )
            assert_no_offenses(cop_name: no_default_cop)
            assert_no_offenses(cop_name: no_return_cop)
          end
        end

        def test_detects_magic_numbers_assigned_to_instance_variables
          matched_numerics.each do |num|
            inspect_source(<<~RUBY, cops: all_cops)
              def test_method
                @set_attribute = #{num}
              end
            RUBY

            assert_no_offenses(cop_name: no_argument_cop)
            assert_offense(
              cop_name: no_assignment_cop.name,
              violation_message: no_assignment_cop.class::INSTANCE_VARIABLE_ASSIGN_MSG
            )
            assert_no_offenses(cop_name: no_return_cop)
          end
        end

        def test_detects_magic_numbers_assigned_via_setters
          matched_numerics.each do |num|
            inspect_source(<<~RUBY, cops: all_cops)
              def test_method
                self.set_attribute = #{num}
              end
            RUBY

            assert_no_offenses(cop_name: no_argument_cop)
            assert_offense(
              cop_name: no_assignment_cop.name,
              violation_message: no_assignment_cop.class::PROPERTY_MSG
            )
            assert_no_offenses(cop_name: no_return_cop)
          end
        end

        def test_detects_magic_numbers_explicitly_returned_from_methods
          matched_numerics.each do |num|
            inspect_source(<<~RUBY, cops: all_cops)
              def test_method
                do_some_things

                return #{num}
              end
            RUBY

            assert_no_offenses(cop_name: no_argument_cop)
            assert_no_offenses(cop_name: no_assignment_cop)
            assert_offense(
              cop_name: no_return_cop.name,
              violation_message: no_return_cop.class::NO_EXPLICIT_RETURN_MSG
            )
          end
        end

        def test_detects_magic_numbers_implicitly_returned_from_methods
          matched_numerics.each do |num|
            inspect_source(<<~RUBY, cops: all_cops)
              def test_method
                #{num}
              end
            RUBY

            assert_no_offenses(cop_name: no_argument_cop)
            assert_no_offenses(cop_name: no_assignment_cop)
            assert_offense(
              cop_name: no_return_cop.name,
              violation_message: no_return_cop.class::NO_EXPLICIT_RETURN_MSG
            )
          end
        end

        def test_detects_magic_numbers_implicitly_returned_from_methods_after_other_things
          matched_numerics.each do |num|
            inspect_source(<<~RUBY, cops: all_cops)
              def test_method
                #{num}
              end
            RUBY

            assert_no_offenses(cop_name: no_argument_cop)
            assert_no_offenses(cop_name: no_assignment_cop)
            assert_offense(
              cop_name: no_return_cop.name,
              violation_message: no_return_cop.class::NO_EXPLICIT_RETURN_MSG
            )
          end
        end

        # rubocop:enable Minitest/MultipleAssertions

        private

        def all_cops
          @all_cops ||= [
            no_argument_cop,
            no_assignment_cop,
            no_default_cop,
            no_return_cop
          ]
        end

        def no_argument_cop
          @no_argument_cop ||= RuboCop::Cop::MagicNumbers::NoArgument.new(config)
        end

        def no_assignment_cop
          @no_assignment_cop ||= RuboCop::Cop::MagicNumbers::NoAssignment.new(config)
        end

        def no_default_cop
          @no_default_cop ||= RuboCop::Cop::MagicNumbers::NoDefault.new(config)
        end

        def no_return_cop
          @no_return_cop ||= RuboCop::Cop::MagicNumbers::NoReturn.new(config)
        end

        def config
          @config ||= RuboCop::Config.new(
            'MagicNumbers/NoArgument' => { 'Enabled' => true },
            'MagicNumbers/NoAssignment' => { 'Enabled' => true },
            'MagicNumbers/NoReturn' => { 'Enabled' => true }
          )
        end
      end
    end
  end
end
