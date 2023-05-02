# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'
require 'custom/no_magic_numbers'

module Custom
  class NoMagicNumbersTest < Minitest::Test
    def test_detects_magic_integers_assigned_to_instance_variables
      inspect_source(<<~RUBY)
        def test_method
          @instance_variable = 1
        end
      RUBY

      assert_offense('Do not use magic number instance variables')
    end

    def test_detects_magic_floats_assigned_to_instance_variables
      inspect_source(<<~RUBY)
        def test_method
          @instance_variable = 1.0
        end
      RUBY

      assert_offense('Do not use magic number instance variables')
    end

    def test_detects_magic_integers_assigned_to_local_variables
      inspect_source(<<~RUBY)
        def test_method
          instance_variable = 1
        end
      RUBY

      assert_offense('Do not use magic number local variables')
    end

    def test_detects_magic_floats_assigned_to_local_variables
      inspect_source(<<~RUBY)
        def test_method
          instance_variable = 1.0
        end
      RUBY

      assert_offense('Do not use magic number local variables')
    end

    def test_detects_magic_integers_assigned_via_attr_writers_on_self
      inspect_source(<<~RUBY)
        def test_method
          self.instance_variable = 1
        end
      RUBY

      assert_offense('Do not use magic numbers to set properties')
    end

    def test_detects_magic_floats_assigned_via_attr_writers_on_self
      inspect_source(<<~RUBY)
        def test_method
          self.instance_variable = 1.0
        end
      RUBY

      assert_offense('Do not use magic numbers to set properties')
    end

    def test_detects_magic_integers_assigned_via_attr_writers_on_another_object
      inspect_source(<<~RUBY)
        def test_method
          foo.instance_variable = 1
        end
      RUBY

      assert_offense('Do not use magic numbers to set properties')
    end

    def test_detects_magic_floats_assigned_via_attr_writers_on_another_object
      inspect_source(<<~RUBY)
        def test_method
          foo.instance_variable = 1.0
        end
      RUBY

      assert_offense('Do not use magic numbers to set properties')
    end

    def test_detects_magic_integers_assigned_to_global_variables
      inspect_source(<<~RUBY)
        def test_method
          $GLOBAL_VARIABLE = 1
        end
      RUBY

      assert_no_offenses("Custom/NoMagicNumbers")

      inspect_source(<<~RUBY)
        $GLOBAL_VARIABLE = 1
      RUBY

      assert_no_offenses("Custom/NoMagicNumbers")
    end

    def test_detects_magic_floats_assigned_to_global_variables
      inspect_source(<<~RUBY)
        $GLOBAL_VARIABLE = 1.0
      RUBY

      assert_no_offenses("Custom/NoMagicNumbers")
    end

    def test_ignores_magic_integers_assigned_via_class_writers_on_another_object
      inspect_source(<<~RUBY)
        def test_method
          Foo.klass_method = 1
        end
      RUBY

      refute_offense
    end

    def test_ignores_magic_floats_assigned_via_class_writers_on_another_object
      inspect_source(<<~RUBY)
        def test_method
          Foo.klass_method = 1
        end
      RUBY

      refute_offense
    end

    private

    def cop
      @cop ||= Custom::NoMagicNumbers.new(config)
    end

    def config
      @config ||= RuboCop::Config.new('Custom/NoMagicNumbers' => { 'Enabled' => true })
    end
  end
end
