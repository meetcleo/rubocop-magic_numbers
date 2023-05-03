# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'
require 'custom/no_magic_numbers'

module Custom
  class SetterAssignmentTest < Minitest::Test
    def setup
      # We detect floats or ints, so this is used in tests to check for both
      @matched_numerics = [1, 1.0]
    end

    def test_detects_magic_numbers_assigned_via_attr_writers_on_self
      @matched_numerics.each do |num|
        inspect_source(<<~RUBY)
          def test_method
            self.test_attr_writer = #{num}
          end
        RUBY

        assert_property_assignment_offence
      end
    end

    def test_detects_magic_numbers_assigned_via_attr_writers_on_another_object
      @matched_numerics.each do |num|
        inspect_source(<<~RUBY)
          def test_method
            foo.test_attr_writer = #{num}
          end
        RUBY

        assert_property_assignment_offence
      end
    end

    private

    def assert_property_assignment_offence
      assert_offense(
        cop_name: cop.name,
        violation_message: described_class::PROPERTY_MSG,
      )
    end

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
