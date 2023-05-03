# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'
require 'custom/no_magic_numbers'

module Custom
  class UnaryMethodTest < Minitest::Test
    def setup
      # We detect floats or ints, so this is used in tests to check for both
      @matched_numerics = [1, 1.0]
    end

    def test_detects_magic_integers_as_arguments_to_unary_methods
      @matched_numerics.each do |num|
        inspect_source(<<~RUBY)
          def test_method
            foo + #{num}
          end
        RUBY

        assert_unary_offense
      end
    end

    private

    def assert_unary_offense
      assert_offense(
        cop_name: cop.name,
        violation_message: described_class::UNARY_MSG,
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
