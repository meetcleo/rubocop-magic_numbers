# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'
require 'custom/no_magic_numbers'

module Custom
  class IgnoredUsagesTest < Minitest::Test
    def setup
      # We detect floats or ints, so this is used in tests to check for both
      @matched_numerics = [1, 1.0]
    end

    def test_ignores_magic_numbers_as_arguments_to_methods_on_another_object
      @matched_numerics.each do |num|
        inspect_source(<<~RUBY)
          def test_method
            foo.inject(#{num})
          end
        RUBY

        refute_offense(cop_name: cop.name)
      end
    end

    def test_ignores_magic_numbers_as_arguments_to_methods_on_self
      @matched_numerics.each do |num|
        inspect_source(<<~RUBY)
          def test_method
            self.inject(#{num})
          end
        RUBY

        refute_offense(cop_name: cop.name)
      end
    end

    def test_ignores_magic_numbers_assigned_to_global_variables
      @matched_numerics.each do |num|
        inspect_source(<<~RUBY)
          def test_method
            $GLOBAL_VARIABLE = #{num}
          end
        RUBY

        refute_offense(cop_name: cop.name)
      end
    end

    def test_ignores_magic_numbers_assigned_to_global_variables_outside_methods
      @matched_numerics.each do |num|
        inspect_source(<<~RUBY)
          $GLOBAL_VARIABLE = #{num}
        RUBY

        refute_offense(cop_name: cop.name)
      end
    end

    def test_ignores_magic_numbers_assigned_via_class_writers_on_another_object
      @matched_numerics.each do |num|
        inspect_source(<<~RUBY)
          def test_method
            Foo.klass_method = #{num}
          end
        RUBY

        refute_offense(cop_name: cop.name)
      end
    end

    private

    def described_class
      Custom::NoMagicNumbers
    end

    def cop
      @cop ||= described_class.new(config)
    end

    def config
      @config ||= RuboCop::Config.new('Custom/NoMagicNumbers' => { 'Enabled' => true })
    end
  end
end
