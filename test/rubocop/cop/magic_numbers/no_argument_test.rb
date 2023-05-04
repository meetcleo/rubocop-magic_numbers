# frozen_string_literal: true

require 'test_helper'
require 'rubocop/cop/magic_numbers/no_argument'

module RuboCop
  module Cop
    module MagicNumbers
      class NoArgumentTest < ::Minitest::Test
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

        private

        def described_class
          RuboCop::Cop::MagicNumbers::NoArgument
        end

        def cop
          @cop ||= described_class.new(config)
        end

        def config
          @config ||= RuboCop::Config.new('MagicNumbers/NoArgument' => { 'Enabled' => true })
        end
      end
    end
  end
end
