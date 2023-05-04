# frozen_string_literal: true

require 'test_helper'
require 'rubocop/no_magic_numbers'

module RuboCop
  module Cop
    module MagicNumbers
      class NoMagicNumbersTest < Minitest::Test
        def test_detects_magic_integers_assigned_to_instance_variables
          inspect_source(<<~RUBY)
            def test_method
              @instance_variable = 1
            end
          RUBY

          assert_offense(
            cop_name: cop.name,
            violation_message: described_class::INSTANCE_VARIABLE_ASSIGN_MSG
          )
        end

        def test_detects_magic_floats_assigned_to_instance_variables
          inspect_source(<<~RUBY)
            def test_method
              @instance_variable = 1.0
            end
          RUBY

          assert_offense(
            cop_name: cop.name,
            violation_message: described_class::INSTANCE_VARIABLE_ASSIGN_MSG
          )
        end

        def test_detects_magic_integers_assigned_to_local_variables
          inspect_source(<<~RUBY)
            def test_method
              local_variable = 1
            end
          RUBY

          assert_offense(
            cop_name: cop.name,
            violation_message: described_class::LOCAL_VARIABLE_ASSIGN_MSG
          )
        end

        def test_detects_magic_floats_assigned_to_local_variables
          inspect_source(<<~RUBY)
            def test_method
              local_variable = 1.0
            end
          RUBY

          assert_offense(
            cop_name: cop.name,
            violation_message: described_class::LOCAL_VARIABLE_ASSIGN_MSG
          )
        end

        def test_detects_magic_integers_assigned_via_attr_writers_on_self
          inspect_source(<<~RUBY)
            def test_method
              self.test_attr_writer = 1
            end
          RUBY

          assert_offense(
            cop_name: cop.name,
            violation_message: described_class::PROPERTY_MSG
          )
        end

        def test_detects_magic_floats_assigned_via_attr_writers_on_self
          inspect_source(<<~RUBY)
            def test_method
              self.test_attr_writer = 1.0
            end
          RUBY

          assert_offense(
            cop_name: cop.name,
            violation_message: described_class::PROPERTY_MSG
          )
        end

        def test_detects_magic_integers_as_arguments_to_unary_methods
          inspect_source(<<~RUBY)
            def test_method
              foo + 1
            end
          RUBY

          assert_offense(
            cop_name: cop.name,
            violation_message: described_class::UNARY_MSG
          )
        end

        def test_detects_magic_floats_as_arguments_to_unary_methods
          inspect_source(<<~RUBY)
            def test_method
              foo + 1.0
            end
          RUBY

          assert_offense(
            cop_name: cop.name,
            violation_message: described_class::UNARY_MSG
          )
        end

        def test_detects_magic_integers_assigned_via_attr_writers_on_another_object
          inspect_source(<<~RUBY)
            def test_method
              foo.test_attr_writer = 1
            end
          RUBY

          assert_offense(
            cop_name: cop.name,
            violation_message: described_class::PROPERTY_MSG
          )
        end

        def test_detects_magic_floats_assigned_via_attr_writers_on_another_object
          inspect_source(<<~RUBY)
            def test_method
              foo.test_attr_writer = 1.0
            end
          RUBY

          assert_offense(
            cop_name: cop.name,
            violation_message: described_class::PROPERTY_MSG
          )
        end

        def test_detects_magic_integers_multiassigned_to_instance_variables
          inspect_source(<<~RUBY)
            def test_method
              @instance_variable, @other_instance_variable = 1, 2
            end
          RUBY

          assert_offense(
            cop_name: cop.name,
            violation_message: described_class::MULTIPLE_ASSIGN_MSG
          )
        end

        def test_detects_magic_floats_multiassigned_to_instance_variables
          inspect_source(<<~RUBY)
            def test_method
              @instance_variable, @other_instance_variable = 1.0, 2.0
            end
          RUBY

          assert_offense(
            cop_name: cop.name,
            violation_message: described_class::MULTIPLE_ASSIGN_MSG
          )
        end

        def test_detects_magic_integers_multiassigned_to_local_variables
          inspect_source(<<~RUBY)
            def test_method
              local_variable, other_local_variable = 1, 2
            end
          RUBY

          assert_offense(
            cop_name: cop.name,
            violation_message: described_class::MULTIPLE_ASSIGN_MSG
          )
        end

        def test_detects_magic_floats_multiassigned_to_local_variables
          inspect_source(<<~RUBY)
            def test_method
              local_variable, other_local_variable = 1.0, 2.0
            end
          RUBY

          assert_offense(
            cop_name: cop.name,
            violation_message: described_class::MULTIPLE_ASSIGN_MSG
          )
        end

        def test_detects_magic_integers_multiassigned_via_attr_writers_on_self
          inspect_source(<<~RUBY)
            def test_method
              self.mutli_test_attr_writer, self.other_mutli_test_attr_writer = 1, 2
            end
          RUBY

          assert_offense(
            cop_name: cop.name,
            violation_message: described_class::MULTIPLE_ASSIGN_MSG
          )
        end

        def test_detects_magic_floats_multiassigned_via_attr_writers_on_self
          inspect_source(<<~RUBY)
            def test_method
              self.mutli_test_attr_writer, self.other_mutli_test_attr_writer = 1.0, 2.0
            end
          RUBY

          assert_offense(
            cop_name: cop.name,
            violation_message: described_class::MULTIPLE_ASSIGN_MSG
          )
        end

        def test_detects_magic_integers_multiassigned_via_attr_writers_on_another_object
          inspect_source(<<~RUBY)
            def test_method
              foo.mutli_test_attr_writer, foo.other_mutli_test_attr_writer = 1, 2
            end
          RUBY

          assert_offense(
            cop_name: cop.name,
            violation_message: described_class::MULTIPLE_ASSIGN_MSG
          )
        end

        def test_detects_magic_floats_multiassigned_via_attr_writers_on_another_object
          inspect_source(<<~RUBY)
            def test_method
              foo.mutli_test_attr_writer, foo.other_mutli_test_attr_writer = 1.0, 2.0
            end
          RUBY

          assert_offense(
            cop_name: cop.name,
            violation_message: described_class::MULTIPLE_ASSIGN_MSG
          )
        end

        def test_ignores_magic_integers_as_arguments_to_methods_on_another_object
          inspect_source(<<~RUBY)
            def test_method
              foo.inject(1)
            end
          RUBY

          refute_offense(cop.name)
        end

        def test_ignores_magic_floats_as_arguments_to_methods_on_another_object
          inspect_source(<<~RUBY)
            def test_method
              foo.inject(1.0)
            end
          RUBY

          refute_offense(cop.name)
        end

        def test_ignores_magic_integers_as_arguments_to_methods_on_self
          inspect_source(<<~RUBY)
            def test_method
              self.inject(1)
            end
          RUBY

          refute_offense(cop.name)
        end

        def test_ignores_magic_floats_as_arguments_to_methods_on_self
          inspect_source(<<~RUBY)
            def test_method
              self.inject(1.0)
            end
          RUBY

          refute_offense(cop.name)
        end

        def test_detects_magic_integers_assigned_to_global_variables
          inspect_source(<<~RUBY)
            def test_method
              $GLOBAL_VARIABLE = 1
            end
          RUBY

          assert_no_offenses(cop.name)

          inspect_source(<<~RUBY)
            $GLOBAL_VARIABLE = 1
          RUBY

          assert_no_offenses(cop.name)
        end

        def test_detects_magic_floats_assigned_to_global_variables
          inspect_source(<<~RUBY)
            $GLOBAL_VARIABLE = 1.0
          RUBY

          assert_no_offenses(cop.name)
        end

        def test_ignores_magic_integers_assigned_via_class_writers_on_another_object
          inspect_source(<<~RUBY)
            def test_method
              Foo.klass_method = 1
            end
          RUBY

          refute_offense(cop.name)
        end

        def test_ignores_magic_floats_assigned_via_class_writers_on_another_object
          inspect_source(<<~RUBY)
            def test_method
              Foo.klass_method = 1
            end
          RUBY

          refute_offense(cop.name)
        end

        private

        def described_class
          RuboCop::Cop::MagicNumbers::NoMagicNumbers
        end

        def cop
          @cop ||= described_class.new(config)
        end

        def config
          @config ||= RuboCop::Config.new('MagicNumbers/NoMagicNumbers' => { 'Enabled' => true })
        end
      end
    end
  end
end
